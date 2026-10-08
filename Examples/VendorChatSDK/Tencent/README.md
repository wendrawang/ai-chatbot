# PoC Tencent Chat untuk host Tanya AI

Ini contoh **host-side**, bukan perubahan pada package TanyaAI. Salin seluruh file
Swift di folder ini ke target host app. Contoh memakai **Tencent Chat Core SDK
edisi Swift** (`ImSDK_Plus_Swift`) dan percakapan C2C antara `userID` nasabah dan
`botUserID`. Jangan pasang TUIKit bila UI chat tetap memakai TanyaAI.
Package **TanyaAI tetap diperlukan** untuk UI, tema, history view, dan kontrak
`TanyaAIChatSession`; yang diganti hanya adapter transport di host.

## Prasyarat

1. Buat aplikasi Chat di konsol Tencent; simpan `SDKAppID` untuk konfigurasi
   host. Tambahkan `pod 'TXIMSDK_Plus_Swift_iOS_XCFramework'` ke target host,
   jalankan `pod install`, dan buka `.xcworkspace`. Samakan versi SDK dengan
   API di file contoh ini saat integrasi.
2. Membuat akun di menu **Users** belum menghasilkan UserSig yang ditampilkan
   di sana. Untuk PoC lokal, buka
   [Chat Console → Development Tools → UserSig Tools](https://console.trtc.io/usersig),
   pilih `SDKAppID`, isi `UserID` akun tadi, klik **Generate**, lalu klik
   **Copy Signature (UserSig)** pada hasil generator. Pakai `UserID` dan
   UserSig tersebut sebagai pasangan pada `connectTencent(userID:userSig:)`.
   Jangan commit UserSig hasil console ke repo; UserSig punya masa berlaku.
   Untuk produksi, backend host harus menerbitkan UserSig bagi nasabah yang
   sudah terautentikasi. `SDKSecretKey` hanya berada di backend.
3. Siapkan `botUserID` Tencent. Uji balasan manual dapat memakai REST API;
   balasan otomatis membutuhkan proses bot/backend yang menerima pesan C2C
   dari nasabah lalu membalas sebagai akun bot. SDK ini infra pesan;
   login dan `sendMessage` saja tidak menghasilkan respons AI.
4. Tentukan kebijakan satu percakapan per nasabah. Contoh ini membaca 20 pesan
   C2C terakhir; pagination history dan pergantian conversation perlu ditambah
   jika menjadi kebutuhan produk.

## Urutan pada struktur RootScreen → Prelogin/MainCoordinator

`RootScreen` tetap memilih `MainCoordinator()` ketika
`appState.state == .loggedIn`. Tidak perlu membuat ulang coordinator.

### AppDelegate: inisialisasi SDK sekali

```swift
@discardableResult
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    let isTencentInitialized = TencentChatLifecycle.shared.initialize(
        sdkAppID: AppConfig.tencentSDKAppID
    )
    if !isTencentInitialized {
        // Laporkan lewat diagnostics aplikasi; jangan tampilkan entry point chat.
    }
    return true
}
```

`SDKAppID` bukan UserSig atau secret.

### AppState: pertahankan alur login host

Pada `login()` yang sudah ada, buat host **sebelum** mengubah state menjadi
`.loggedIn`, agar `MainCoordinator` sejak pertama kali tampil mendapat objek
host yang stabil. Setelah login host berhasil dan pasangan `userID`/UserSig
Tencent tersedia, jalankan `connectTencent`:

```swift
@Published private(set) var isTencentReady = false
@Published private(set) var tanyaAIHost: TanyaAIHost?
@Published private(set) var pendingChatDeeplink: URL?
@Published private(set) var tencentLoginError: Error?

func prepareTanyaAI(theme: TanyaAITheme = .sandbox) {
    guard tanyaAIHost == nil else { return }
    let composition = TencentTanyaAIComposition(
        botUserID: AppConfig.tencentBotUserID,
        deeplinkScheme: "ocbcid",
        deeplinkHost: "mobile"
    )
    tanyaAIHost = composition.makeHost(theme: theme) { [weak self] url in
        self?.pendingChatDeeplink = url
    }
}

func connectTencent(userID: String, userSig: String) {
    isTencentReady = false
    tencentLoginError = nil
    TencentChatLifecycle.shared.login(userID: userID, userSig: userSig) { [weak self] result in
        DispatchQueue.main.async {
            guard let self, self.state == .loggedIn else { return }
            switch result {
            case .success:
                self.isTencentReady = true
            case .failure(let error):
                self.isTencentReady = false
                self.tencentLoginError = error
            }
        }
    }
}

func consumeDeeplink() -> URL? {
    let url = pendingChatDeeplink
    pendingChatDeeplink = nil
    return url
}
```

Panggil `prepareTanyaAI()` tepat sebelum `state = .loggedIn`, lalu
`connectTencent` sekali per sesi login yang berhasil setelah mengambil UserSig
dari console (PoC) atau backend (produksi). Bila UserSig kedaluwarsa atau akun
ter-kick, ambil UserSig
baru dan login ulang melalui state aplikasi. Pemanggilan dari `login()` AppState
aman ketika login host sudah berhasil, SDK sudah diinisialisasi, dan method ini
dijalankan pada main thread. Mengubah state ke `.loggedIn` tidak membuka chat;
entry point Main menunggu `isTencentReady` sebelum memanggil `present()`.
`theme:` dapat menerima snapshot tema host; `.sandbox` hanya default contoh PoC.

Saat logout, tutup chat, reset readiness/error/pending URL, lalu logout SDK:

```swift
func clearTanyaAI(completion: @escaping () -> Void = {}) {
    isTencentReady = false
    tencentLoginError = nil
    pendingChatDeeplink = nil
    let host = tanyaAIHost
    tanyaAIHost = nil
    let logoutTencent = {
        TencentChatLifecycle.shared.logout {
            DispatchQueue.main.async(execute: completion)
        }
    }
    if let host {
        host.dismiss(completion: logoutTencent)
    } else {
        logoutTencent()
    }
}
```

Tunggu completion ini sebelum login Tencent dengan akun berikutnya. Menutup
layar TanyaAI biasa **tidak** memanggil logout SDK. Callback login juga memeriksa
state aplikasi, sehingga hasil yang tiba setelah logout tidak mengaktifkan tombol
di halaman prelogin.

### MainCoordinator: tap entry point baru membuka chat

`MainCoordinator` tetap anak RootScreen. Pasang `.tanyaAIHost(host)` pada root
`NavigationView` di Main, dan panggil `present()` hanya saat tombol ditekan:

```swift
@EnvironmentObject var appState: AppState

var body: some View {
    mainContent
        .tanyaAIHost(appState.tanyaAIHost)
        .onReceive(appState.$pendingChatDeeplink) { pending in
            guard pending != nil, let url = appState.consumeDeeplink() else { return }
            openExistingDeeplink(url)
        }
}

private var mainContent: some View {
    NavigationView {
        Button("Tanya AI") { appState.tanyaAIHost?.present() }
            .disabled(!appState.isTencentReady)
        // Konten Main Anda yang lain tetap di sini.
    }
}
```

Modifier menerima `TanyaAIHost?` langsung; tidak perlu `!`, unwrap manual, atau
memindahkan NavigationView ke dua cabang. Nil hanya menghilangkan anchor chat,
sementara konten dan state Main tetap pada identitas yang sama. Method
`openExistingDeeplink` pada contoh adalah router milik host, bukan API package.

`TanyaAIHost` menutup fitur sebelum callback deeplink. Callback hanya menaruh
URL di `AppState`; `MainCoordinator` yang menjalankan router existing, sesuai
batas navigasi host Anda. Gunakan URL `https` atau scheme/host lain hanya bila
memang didaftarkan dalam `TanyaAIHost` dan diizinkan router host.

### Apa yang terjadi saat chat dibuka

Package memanggil `makeSession` (instance **baru** setiap presentasi), lalu
`connect()`. Adapter memasang listener, mengambil history C2C, mengirim
`.history` dan `.connected`. Saat nasabah menekan kirim, package memanggil
`send(text:...)`; adapter mengirim pesan ke `botUserID`. Balasan C2C dari bot
diterjemahkan menjadi konten dan `messageCompleted`; live/history memakai
pemetaan yang sama. Saat chat ditutup, adapter hanya melepas listener. Login
Tencent tetap hidup sampai logout host. Tidak ada greeting otomatis.

## Uji balasan bot tanpa backend AI

Untuk memastikan bubble balasan bekerja, pakai **SDKAppID yang sama** untuk
akun nasabah dan akun bot. `botUserID` pada `TencentTanyaAIComposition` harus
persis sama dengan ID akun bot. Buka Tanya AI di app nasabah, lalu kirim teks
dari akun bot ke `userID` nasabah. Ada dua cara mengirim teks uji:

1. Dari terminal yang dapat mengakses Tencent, backend, atau
   [REST API debugger Tencent](https://www.tencentcloud.com/document/product/1047/34919),
   panggil `v4/openim/sendmsg` memakai `identifier` dan UserSig **app admin**.
   Isi body berikut; `From_Account` adalah `botUserID`, `To_Account` adalah
   `userID` nasabah yang sedang login:

   ```json
   {
     "SyncOtherMachine": 2,
     "From_Account": "bot_poc",
     "To_Account": "wen",
     "MsgRandom": 123456789,
     "MsgBody": [
       {
         "MsgType": "TIMTextElem",
         "MsgContent": { "Text": "Halo Wen, ini balasan dari bot_poc." }
       }
     ]
   }
   ```

   Gunakan `MsgRandom` baru untuk setiap pengiriman. Admin UserSig dan
   `SDKSecretKey` hanya boleh dipakai di backend/alat uji, bukan di host app.
   Periksa `ActionStatus` dan `ErrorCode` pada respons REST, bukan hanya HTTP
   200. Jangan set `OnlineOnlyFlag: 1` untuk uji history karena pesan itu tidak
   disimpan dalam riwayat.
2. Atau login akun bot pada **proses aplikasi lain** dengan UserSig milik bot,
   lalu kirim pesan C2C ke `userID` nasabah. Jangan logout akun nasabah lalu
   login bot pada host yang sama: `V2TIMManager.shared` menyimpan satu sesi
   login per proses.

Jalankan contoh `curl` di `send_test_reply.sh` dari root repo. Ganti
`SDKAppID_ANDA` dengan SDKAppID yang sama seperti di host app. Domain di
bawah **hanya contoh region Jakarta**; pilih domain REST sesuai region
SDKAppID di [dokumentasi Tencent](https://www.tencentcloud.com/document/product/1047/34919).
Script akan meminta UserSig app admin tanpa menampilkannya saat diketik.

```sh
TENCENT_SDK_APP_ID='SDKAppID_ANDA' \
TENCENT_REST_HOST='adminapiidn.im.qcloud.com' \
sh Examples/VendorChatSDK/Tencent/send_test_reply.sh
```

`TENCENT_ADMIN_SIG` adalah UserSig untuk **app admin** (`administrator` secara
default; ganti lewat `TENCENT_ADMIN_ID` bila console menunjukkan ID lain),
bukan UserSig nasabah `wen` atau bot `bot_poc`. Buat UserSig untuk ID admin
melalui UserSig Tools saat PoC. SDKAppID **wajib** untuk request REST;
`SDKSecretKey` **tidak diperlukan** oleh script maupun request. Secret hanya
dipakai saat membuat UserSig dan harus disimpan di backend. Akun `bot_poc`
dan `wen` harus ada pada SDKAppID yang sama. `curl` modern diperlukan untuk
opsi `--url-query`.

Jalankan dari mesin/server yang **bisa** menjangkau API Tencent. Bila Mac
kantor memblokir Tencent, `curl` di Mac itu juga akan terblokir walaupun
iPhone di jaringan seluler dapat menerima pesannya. Setelah script berjalan,
periksa `ActionStatus: "OK"` dan `ErrorCode: 0` pada respons.

Balasan yang berhasil diterima oleh listener akan menjadi bubble assistant;
setelah layar ditutup dan dibuka lagi, pesan tersebut dibaca dari history C2C.
Adapter hanya menampilkan **teks** saat ini, jadi custom message, suggestion,
dan bubble kaya tidak akan tampil tanpa pemetaan payload tambahan.

Untuk membuat respons otomatis, aktifkan callback
[`C2C.CallbackAfterSendMsg`](https://trtc.io/document/34365) ke backend.
Saat callback berasal dari nasabah ke `botUserID`, berhasil (`SendMsgResult`
bernilai `0`), dan memuat `TIMTextElem`, backend dapat mengirim teks balasan
melalui `v4/openim/sendmsg` dengan `From_Account = botUserID` dan
`To_Account = From_Account` pada callback. Abaikan callback yang berasal dari
bot agar balasan bot tidak memicu loop. Untuk PoC echo, teks respons dapat
berupa `"Echo: " + pesanNasabah`; untuk balasan AI, ganti pembuat teks di
backend. Jangan taruh logic atau kredensial bot di package TanyaAI.

## Custom bubble dan kontrak terbaru

Adapter membaca `TIMTextElem` serta seluruh rantai `TIMCustomElem` untuk live dan
history. Update DesignKit/TanyaAI bersama dan salin **seluruh** file Swift folder
ini, termasuk `TencentChatSessionAdapter+Contract.swift`. Kontrak `Data`, aturan
radio terbaru, callback `destination_type`, dan handoff PIN dijelaskan lengkap
di [TENCENT_MESSAGE_CONTRACT.md](../../../docs/TENCENT_MESSAGE_CONTRACT.md).

Jalankan `sh send_test_reply.sh answer` untuk kombinasi teks/radio/kartu/link.
Argumen lainnya: `text`, `radio`, `info`, `link`, `confirmation`.
Script membutuhkan Python 3; sender default `bot_poc`, recipient default `wen`.

## Batas PoC ini

- `context`/`requestIdentifier` belum dikirim sebagai metadata Tencent; kontrak
  backend harus menetapkan jalurnya. Teks radio menggunakan label sebagai prompt;
  `value` dipertahankan sebagai ID pilihan.
- History tetap 20 pesan C2C terakhir. Pagination membutuhkan backend/host policy.
- Konfirmasi baru mengirim confirmation ID/fields ke flow PIN host, tanpa
  memalsukan challenge atau menjalankan transaksi di package.
- Runtime Tencent/login dan pengiriman REST tetap diuji pada host/device Anda.

Referensi API: [integrasi SDK iOS](https://trtc.io/document/34307),
[Swift V2TIMManager](https://im.sdk.qcloud.com/doc/en/swift_V2TIMManager.html),
[pesan dan history](https://im.sdk.qcloud.com/doc/en/swift_V2TIMManager%2BMessage.html).
