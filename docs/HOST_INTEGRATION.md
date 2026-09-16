# Memasang TanyaAI di host app

Mulai dari dummy untuk memeriksa bubble. Setelah UI sesuai, ganti pembuat session
ke adapter backend; komponen bubble tidak perlu diubah.

## 1. Tambahkan package

Pertahankan posisi kedua folder:

```text
Packages/
  DesignKit/Package.swift
  TanyaAI/Package.swift
```

Di Xcode, tambahkan local package `Packages/TanyaAI` dan `Packages/DesignKit`.
Hubungkan product berikut ke target yang sesuai:

| Target | Product |
| --- | --- |
| Host produksi | `TanyaAI`, `DesignKit` |
| Target demo/Debug | `TanyaAI`, `DesignKit`, `TanyaAITestSupport` |

Paling sederhana memakai target demo terpisah. `#if DEBUG` menjaga pemakaian
source dummy, tetapi **tidak otomatis menghapus linkage package dari Release**.
Pastikan target Release tidak menghubungkan `TanyaAITestSupport`.

## 2. Jalankan dummy di host SwiftUI

Salin dua file yang sudah tersedia ke target demo:

- [DemoTanyaAIComposition.swift](../Examples/Demo/DemoTanyaAIComposition.swift)
- [DemoTanyaAIScreen.swift](../Examples/Demo/DemoTanyaAIScreen.swift)

Lalu gunakan pada menu developer atau halaman percobaan:

```swift
#if DEBUG
DemoTanyaAIScreen { url in
    print("Demo hand-off:", url)
}
#endif
```

Tap **Lihat semua bubble**. Chat otomatis mengirim `showcase` dan menampilkan
fixture. Callback di atas hanya mencetak URL; sambungkan ke router host jika ingin
menguji halaman tujuan. Fixture memakai `ocbcid://mobile`; filter demo sudah cocok.

Tidak ada backend chat yang perlu dinyalakan. Gambar remote tetap membutuhkan
internet; jika gagal, bubble menampilkan placeholder. PIN dummy yang diterima:
**123456**. PIN lain menguji tampilan error. Tidak ada transaksi sungguhan.

Ingin menulis wiring sendiri? Ini contoh lengkap pengganti dua file tersebut:

```swift
#if DEBUG
import SwiftUI
import TanyaAI
import TanyaAITestSupport

struct ChatDemoPage: View {
    @StateObject private var host = TanyaAIHost(
        theme: .sandbox,
        authorizationService: MockTanyaAIAuthorizationService(),
        deeplinkScheme: "ocbcid",
        deeplinkHost: "mobile",
        initialPrompt: "showcase",
        makeSession: { MockTanyaAIChatSession.sandbox() },
        onDeeplink: { url in print("Demo hand-off:", url) }
    )

    var body: some View {
        Button("Buka TanyaAI") { host.present() }
            .tanyaAIHost(host)
    }
}
#endif
```

`.tanyaAIHost(host)` dipasang sekali pada root yang memiliki host. `present()`
baru bekerja setelah root tampil. Fitur dipresentasikan sebagai controller sendiri,
bukan di-push ke NavigationView host. `@StateObject` mempertahankan identitas host;
jangan membuat instance baru pada setiap evaluasi `body`.

## 3. Cek bubble tertentu

Hapus `initialPrompt: "showcase"` jika ingin mengetik manual.

| Ketik persis | Respons dummy |
| --- | --- |
| `showcase` | Koleksi bubble untuk review |
| `transfer` | Approval transfer dan alur PIN |
| `currency` / `conversion` | Approval konversi mata uang |
| `deposit` | Approval deposito |
| `saving` | Approval tabungan berjangka |
| `spending` | Chart pengeluaran |
| `incoming` | Daftar dana masuk |
| `bill` | Daftar tagihan |
| `limit` | Informasi limit |
| `deeplink` | Link menuju halaman host |
| Teks lainnya | Portfolio |

Keyword fixture memakai pencarian substring berbahasa Inggris; gunakan kata di
tabel agar hasilnya pasti. `showcase` mencakup gambar, choices, HTML, live agent,
dan suggestion. Gunakan [JSON bubble](BUBBLE_SCHEMA.md) untuk payload buatan sendiri.

Tanpa host app, jalankan aplikasi sandbox dari root repository:

```sh
./Scripts/run_sandbox.sh --showcase
```

## 4. Gunakan tema dan font host

Lakukan sekali saat setup pada main actor, sebelum membuat host:

```swift
import DesignKit

try DesignKitFont.registerFonts()
let manager = ThemeManager(fonts: .branded(), selected: .premier)
let selectedTheme = manager.theme
let defaultTheme = manager.resolve(isDefaultForced: true)
```

Masukkan `selectedTheme` atau `defaultTheme` ke parameter `theme:` pada
`TanyaAIHost`, atau `DemoTanyaAIScreen(theme: selectedTheme, onDeeplink: handler)`.
Tangani error registrasi font di setup aplikasi.

`TanyaAIHost` menyimpan snapshot theme saat dibuat. Perubahan manager tidak
mengubah chat UIKit yang sudah terbuka. Buat host dengan snapshot terbaru ketika
mengganti konfigurasi tema, lalu attach host tersebut sebelum presentasi berikutnya.
Untuk komponen SwiftUI langsung, `.theme(manager)` mengikuti perubahan secara live;
`.theme(manager, isDefaultForced: true)` mengunci satu subtree ke default.

Premier/Private masih dummy; Default dan size berupa transkripsi foto, bukan export
resmi engine. Ganti dengan export asli sebelum menggunakan palette produksi.
Lihat [panduan DesignKit](DESIGNKIT_THEMES.md) untuk mapping dan font tambahan.

## 5. Ganti dummy dengan session backend

Pertahankan view host. Ganti `makeSession` menjadi closure yang membuat adapter
`TanyaAIChatSession` baru setiap chat dibuka. `TanyaAIHost` menerima:

| Parameter | Isi |
| --- | --- |
| `theme` | Snapshot `Theme` |
| `authorizationService` | Service PIN host; boleh nil jika semua approval memakai hand-off |
| `deeplinkScheme`, `deeplinkHost` | Scheme/host URL yang boleh diteruskan |
| `initialPrompt` | Pesan pertama otomatis; nil untuk tanpa pesan otomatis |
| `shortcuts` | `[TanyaAISuggestion]` dari host, ditampilkan di atas input |
| `makeSession` | Factory session baru per presentasi |
| `onDeeplink` | Router host, dipanggil sesudah chat selesai ditutup |

Contoh implementasi berada di [Examples/HostIntegration](../Examples/HostIntegration/)
dan [Examples/VendorChatSDK](../Examples/VendorChatSDK/). Adapter vendor adalah
referensi integrasi; cocokkan dengan versi SDK yang dipasang di host.

Tanggung jawab adapter:

1. `connect()`: baca history, emit `.history(...)`, lalu `.connected`.
   Session tanpa history dapat langsung emit `.connected`.
2. `send(...)`: kirim pertanyaan pengguna ke backend.
3. Respons backend: terjemahkan menjadi event package seperti panduan JSON.
4. Akhiri turn dengan `.messageCompleted(...)`, atau `.failed(error)` bila gagal.
5. `disconnect()`: bersihkan callback/delegate milik fitur, bukan koneksi global SDK.

Tanggung jawab authorization service: terima challenge dan PIN, panggil API host,
lalu kembalikan status transaksi. Jangan gunakan mock authorization di produksi.
PIN tidak boleh dicatat atau disimpan. Jika service nil dan approval tidak memiliki
`handoff`, konfirmasi akan ditolak dengan pesan, bukan dianggap berhasil.

Host tetap memvalidasi parameter dan hak akses deeplink sesudah filter scheme/host.
Untuk UIKit murni, lihat [contoh presentasi UIKit](HOST_UIKIT.md).

## Kenapa wiring ini tetap ringan?

Satu host yang dipertahankan, satu session per presentasi, dan satu kali registrasi
font. Gunakan renderer package; tidak perlu membuat ulang ViewModel, parser JSON,
cache gambar, atau UITableView di host. Riwayat dan transcript aktif dibatasi 100
pesan. Gambar di-downsample dan update streaming digabung sebelum layout.
