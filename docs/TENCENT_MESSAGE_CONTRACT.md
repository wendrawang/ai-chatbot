# Kontrak Tencent dan perubahan host

Gunakan versi DesignKit/TanyaAI yang sudah mendukung kontrak ini. Migrasi transport
C2C ke group tidak mengubah kedua package; salin empat file Swift pada root
`Examples/VendorChatSDK/Tencent` ke target host, tanpa folder `Tests`. Termasuk
`TencentChatSessionAdapter+Contract.swift`. Pertahankan modifier `.tanyaAIHost(host)`
di Main dan entry point yang memanggil `host.present()` saat tombol ditekan.
SDK init/login/AppState tetap; konfigurasi composition sekarang memakai `groupID`.
`initialPrompt: nil` tidak mengirim chat
otomatis; membuka sesi hanya mengambil history dan memasang listener.

## Envelope dan isi pesan

Teks menggunakan `TIMTextElem` dengan `MsgContent.Text`. Konten custom menggunakan
`TIMCustomElem`; `MsgContent.Data` merupakan **string berisi JSON UTF-8**.
Jangan kirim JSON custom sebagai `TIMTextElem`, dan jangan base64-kan `Data`.
SDK memberi `customElem.data` berupa `Data`, jadi adapter tidak perlu membaca
ulang envelope REST ataupun decrypt sendiri.

Satu `MsgBody` dapat memuat teks dan beberapa custom element. Adapter membaca
rantai `getNextElem()` lalu mempertahankan satu `msgID` sebagai satu jawaban.
Semua 15 kombinasi teks/radio/info/link didukung; urutan tampilan tetap teks →
radio → kartu → link. Maksimal satu kelompok radio dan satu info card per
jawaban, dengan beberapa link. Kartu konfirmasi dikirim dalam pesan tersendiri.
Payload malformed/tipe tidak dikenal tampil sebagai fallback terlokalisasi,
bukan JSON mentah atau kontrol yang dapat mengeksekusi aksi.

Contoh `MsgBody` siap pakai ada di
[Fixtures](../Examples/VendorChatSDK/Tencent/Fixtures/answer.json).
Bentuk isi custom setelah `Data` dibaca:

```json
{"type":"radio_button","options":[
  {"label":"Cashback Belanja 10%","value":"promo_cashback10"},
  {"label":"Bunga Deposito Spesial 6%","value":"promo_deposito6"}
]}
```

`value` adalah identifier stabil option; `label` adalah teks yang terlihat dan
menjadi prompt `TIMTextElem` ketika dipilih, sesuai perilaku auto-prompt yang
diminta. Package tidak mengirim kode seperti `promo_cashback10` sebagai teks
percakapan. Bila backend perlu ID pilihan sebagai metadata, sepakati kanal
metadata terpisah pada adapter; jangan menyisipkannya ke teks nasabah.

Radio hanya tersedia pada **pesan terakhir**. Tap satu option langsung mengirim
prompt dan menyembunyikan semua option jawaban itu. Pesan baru juga menyembunyikan
radio pada jawaban lama, termasuk saat history dipulihkan. Update/replay pesan
lama tidak menghidupkannya lagi. Teks, kartu, dan link tetap terlihat.

```json
{"type":"info_card","title":"Cashback Belanja 10%",
 "description":"Dapatkan cashback 10% untuk transaksi kartu debit OCBC di merchant pilihan, berlaku s.d. 31 Des 2026",
 "image":"https://cdn.ocbc.co.id/promo/cashback10-detail.jpg"}
```

Title dan description tetap terpisah, keduanya tampil di bawah gambar.
Rasio default kartu dipakai karena kontrak tidak memberi ukuran gambar;
image loader tetap memiliki cache terbatas dan cancellation.

```json
{"type":"link_button","label":"Bicara dengan Agent",
 "target":"ocbcid://mobile?type=live-chat&identifier=investasi",
 "destination_type":"deeplink"}
```

`destination_type` wajib: `deeplink`, `webview`, atau `browser`. Untuk deeplink,
handler `onDeeplink` lama tetap bekerja. Webview/browser memerlukan
`onDestination`; package hanya meneruskan URL HTTPS dan tidak membuka URL sendiri.
Host memvalidasi domain dan menentukan apakah destinasi boleh dibuka. Callback
baru menerima tipe asli melalui `action.destinationType` setelah chat selesai
menutup, jadi router tetap dapat dijalankan hanya dari Main.

## Setup callback di host

```swift
let composition = TencentTanyaAIComposition(
    groupID: groupIDFromBackend, deeplinkScheme: "ocbcid", deeplinkHost: "mobile"
)
let host = composition.makeHost(
    theme: selectedTheme,
    onDestination: { [weak appState] action, url in
        // Simpan URL + action.destinationType di AppState.
        // Main memvalidasi domain dan menjalankan deeplink/webview/browser.
        appState?.receiveChatDestination(action.destinationType, url: url)
    },
    onConfirmation: { [weak appState] payload in
        // Main membuka flow PIN milik aplikasi untuk confirmationIdentifier ini.
        appState?.receiveChatConfirmation(payload)
    },
    onDeeplink: { [weak appState] url in
        appState?.pendingTanyaAIDeeplink = url
    }
)
```

`receiveChatDestination` dan `receiveChatConfirmation` adalah method host yang
Anda buat untuk menaruh intent di AppState; bukan API package. Jika
`onDestination` dipasang, callback itu menangani ketiga tipe, termasuk deeplink.
Jika tidak dipasang, hanya deeplink valid yang mencapai `onDeeplink`.

## Konfirmasi dan PIN

```json
{"type":"confirmation_card","confirmation_id":"conf_7c2ab9","fields":[
  {"key":"from","label":"Dari","value":"Tabungan · 6210"},
  {"key":"to","label":"Ke","value":"Giro · 8842"},
  {"key":"amount","label":"Jumlah","value":"Rp2.000.000","raw_value":2000000},
  {"key":"fee","label":"Biaya","value":"Gratis"}
]}
```

Setiap kartu mempunyai tombol Konfirmasi. Tap meneruskan `confirmationIdentifier`
dan seluruh `fields` ke `onConfirmation` **setelah dismissal selesai**; host
memulai flow PIN existing. Kedatangan kartu tidak otomatis meminta PIN. Tap ganda
pada presentasi yang sama diblokir. Tanpa callback, UI memberi error terlokalisasi.
`raw_value` numeric disimpan sebagai `Decimal`, terpisah dari display `value`.

Kontrak ini belum membawa transaction ID, challenge, expiry, endpoint otorisasi,
atau hasil transaksi. Package tidak mengarang nilai tersebut dan tidak memakai
kartu ini untuk mengeksekusi transfer. Host mengambil challenge/rincian otoritatif
dari backend berdasarkan confirmation ID sebelum menjalankan PIN. Kontrak
`approval` lama dan `authorizationService` tetap tersedia untuk integrasi yang
memang membawa data challenge lengkap.

## Uji REST manual

Dari direktori Tencent, dengan pasangan admin ID/UserSig yang sesuai:

```sh
TENCENT_GROUP_ID='GroupId_Anda' \
TENCENT_SDK_APP_ID='SDKAppID_Anda' \
TENCENT_REST_HOST='adminapiidn.im.qcloud.com' \
sh send_test_reply.sh answer
```

Domain harus sama dengan region aplikasi Tencent. Script meminta **UserSig app
admin**, bukan UserSig `wen` atau `bot_poc`. Default sender `bot_poc`, target
adalah `TENCENT_GROUP_ID`; nasabah dan bot harus menjadi anggota group.
Gunakan argumen `text`, `radio`, `info`, `link`, `confirmation`, atau
`answer`; script memerlukan Python 3 untuk menghasilkan JSON dan `Random`
baru, serta memeriksa `ActionStatus`/`ErrorCode`. Tidak membutuhkan secret key.
Endpoint reply: `v4/group_open_http_svc/send_group_msg`; envelope memakai
`GroupId` dan `Random`, tanpa `To_Account`/`MsgRandom` C2C. Untuk akun bot lain,
set `TENCENT_BOT_ID`. Perintah `create-group` menyiapkan Public group PoC dengan join/invite SDK ditutup
dengan owner `TENCENT_USER_ID` (default `wen`) dan anggota bot. Lihat
[panduan group host](../Examples/VendorChatSDK/Tencent/README.md).

Live dan history menggunakan pemetaan yang sama. Urutan batch history Tencent
dibalik dari newest-first, tanpa mengurutkan ulang timestamp yang bisa sama.
Membuka ulang chat tidak
mengirim greeting; respons awal dapat berasal dari history atau bot yang mengirim
pesan sendiri. Pengiriman REST nyata tetap perlu diverifikasi pada host dengan
SDK/login Anda.

API rantai elemen diperiksa terhadap
[dokumentasi Swift Tencent](https://im.sdk.qcloud.com/doc/en/swift_V2TIMElem.html).
