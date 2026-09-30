# 3Dolphins di host app

Adapter ini mengikuti API pada foto dokumentasi iOS yang diberikan: setup,
profil, notifikasi, kirim teks, dan tutup sesi. SDK tetap dependency host;
package TanyaAI tidak mengimpor SDK vendor.

Foto backend berjudul **Inbound Message (3Dolphins to 3rd Party Apps)**
menjelaskan webhook HTTP ke backend. `chatbotConversation` merupakan string
transkrip pada contoh tersebut, bukan kontrak notifikasi SDK iOS. Jangan
menggunakannya untuk menebak field pesan, urutan streaming, atau ID bubble.

Contoh alur aplikasi lengkap tersedia di [HostApp](HostApp/README.md): AppDelegate,
login, tombol chat, router deeplink, dan logout.

## 1. Pasang dependency dan contoh

Tambahkan SDK `imi_dolphin_livechat_ios` sesuai distribusi vendor, serta produk
`TanyaAI` ke target host. Salin file Swift dalam folder ini ke target host.
SDK vendor tidak tersedia dalam repository ini; signature harus diverifikasi
terhadap versi SDK terpasang. Folder Examples diperiksa oleh style checker.

## 2. Inisialisasi SDK dan profil

Jalankan di main thread setelah konfigurasi environment dan identitas user siap,
sebelum membuka chat. Nilai di bawah merupakan contoh dummy, bukan kredensial aktif.

```swift
let configuration = ThreeDolphinsConfiguration(
    baseURL: "https://livechat.example.com",
    clientIdentifier: "dummy-client",
    clientSecret: "dummy-secret",
    botIdentifier: "dummy-bot"
)
configuration.configure()

let profile = DolphinProfile(
    name: "Demo User",
    email: "demo@example.com",
    phoneNumber: "080000000000",
    customerId: "customer-demo",
    uid: "user-demo"
)
```

`configure()` memanggil `setupConnection(baseUrl:clientId:clientSecret:botId:)`
sesuai source SDK pada foto terbaru. Cocokkan label `clientSecret` dengan SDK yang terpasang; contoh
lama menggunakan ejaan berbeda. Ganti konfigurasi dummy dengan konfigurasi host.
Jangan memanggil setup dari `View.body` atau pada setiap kirim pesan.

## 3. Mapping pesan native

Source SDK pada foto menunjukkan `notificationMessage` mengirim `DolphinMessage`
melalui `notification.object`. Jalur incoming memakai `msgDecrypted`, lalu
menandai `isUser = false`. Mapper sekarang membaca objek itu, bukan userInfo.

`ThreeDolphinsMessageMapper.map` menangani **pesan teks utuh**:

- `message` menjadi teks bubble tanpa dekripsi ulang di host.
- `transactionId` dipakai sebagai ID jika tersedia; fallback UUID untuk pesan tanpa ID.
- `isUser == true` diabaikan agar echo customer tidak menjadi bubble assistant.
- Pesan tanpa teks/whitespace diabaikan, bukan dianggap error parsing.
- Tiga event start/delta/completed memakai ID yang sama.

Untuk composition, gunakan `mapMessage: ThreeDolphinsMessageMapper.map`.
Helper `events(name:payload:)` tetap tersedia untuk envelope TanyaAI eksplisit,
misalnya fixture atau bridge host. Jangan mengasumsikan `message.event` atau
`customVariables` berisi nama/payload bubble TanyaAI.

**Batas patch:** belum menangani streaming native, attachment, carousel, atau
history secara lengkap. Foto menunjukkan SDK mengirim history lewat notifikasi
yang sama; `isUser` membedakan pengirim, tetapi tidak membedakan history/live.
Dengan mapper teks ini, history assistant dapat tampil sebagai pesan live dan
history customer diabaikan. Jangan gunakan sebagai integrasi history produksi.
Diperlukan sinyal awal/akhir history dan semantik messageType/state sebelum
menambahkan batching history atau menggabungkan potongan streaming.

Nama dan payload bubble eksplisit ada di [schema bubble](../../../docs/BUBBLE_SCHEMA.md).

## 4. Buat host

Contoh berikut memakai mapper teks native pada langkah 3.

```swift
import UIKit

let composition = ThreeDolphinsTanyaAIComposition(
    profile: profile,
    deeplinkScheme: "ocbcid",
    deeplinkHost: "mobile",
    mapMessage: ThreeDolphinsMessageMapper.map
)

let host = composition.makeHost(
    theme: .sandbox,
    silentGreeting: "Halo",
    onDeeplink: { destination in
        // Teruskan destination ke router milik host.
        UIApplication.shared.open(destination)
    }
)
```

Simpan host sebagai `@StateObject` pada pemilik layar SwiftUI, pasang
`.tanyaAIHost(host)`, lalu panggil `host.present()` dari tombol.
Untuk UIKit, gunakan [panduan host UIKit](../../../docs/HOST_UIKIT.md).
`authorizationService` bisa disuntikkan jika memakai alur PIN package.

`silentGreeting` default nil. Jika diisi, adapter mengirimkannya sekali setelah
status Connected, tanpa bubble customer. Ini berbeda dari `initialPrompt`
yang tampil sebagai pesan customer. Jangan aktifkan keduanya untuk greeting sama.

## 5. Lifecycle

1. Host mengonfigurasi SDK dan membangun profil.
2. TanyaAI memanggil factory `makeSession` saat presentasi; selalu instance baru.
3. Adapter memasang observer sebelum `constructConnector(profile:)`.
4. Status dibaca dari `notification.object` sesuai source SDK pada foto terbaru.
5. Connected (2) menghasilkan `.connected`; greeting opsional dikirim sekali.
6. `send(...)` memanggil `onSendMessage(messages:)`.
7. `disconnect()` melepas observer sebelum `endActiveSession()`.

Status 4 berarti disconnected, 5 connection error, dan 6 attachment error.
Status 1/3 tidak diterjemahkan menjadi error. Callback dan pemanggilan SDK
adapter diserialkan pada main thread. Observer memakai weak capture.

`Connector.shared` bersifat singleton: gunakan satu sesi chat aktif dalam host.
Penutupan sesi background mengikuti kebijakan aplikasi; adapter tidak memasang
observer background sendiri. Pemanggilan connect/disconnect berulang dijaga.

## Batas yang eksplisit

- Mapper teks utuh memakai DolphinMessage dari foto; lifecycle streaming belum terverifikasi.
- History tidak dipanggil karena API/key history tidak ditunjukkan dalam foto.
- `context` dan `requestIdentifier` tidak dikirim sebagai teks. Semantik metadata
  `dataUser` dan korelasi request belum dijelaskan oleh dokumen.
- Carousel native perlu dipetakan dari model SDK asli; belum ada asumsi field carousel.
- Attachment mengikuti `attachmentManager.validateFileMimeType(url:)` lalu
  `sendAttachment(fileNsUrl:state:)` di host. Protocol TanyaAIChatSession saat ini
  hanya mengirim teks, sehingga contoh ini tidak menambah UI upload.
- Kontrak SDK asli dan koneksi backend belum dapat diuji tanpa package vendor
  dan environment. Pengujian stub tidak menggantikan build dengan SDK vendor.

## Verifikasi contoh

Style checker lulus tanpa pelanggaran. Keempat file Swift dikompilasi dengan
stub SDK dan kontrak event TanyaAI asli; pengujian memeriksa setup, koneksi
sinkron, connect/status berulang, greeting sekali, kirim teks, reconnect,
payload malformed, completion bubble, streaming, pelepasan observer dan instance.
Ini tidak memverifikasi ABI/signature SDK vendor atau koneksi server nyata.
