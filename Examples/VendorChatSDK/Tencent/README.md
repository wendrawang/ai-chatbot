# PoC Tencent Chat untuk host Tanya AI

Ini contoh **host-side**, bukan perubahan pada package TanyaAI. Salin tiga file
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
2. Untuk PoC lokal, buka [Chat Console → Development Tools → UserSig Tools](https://console.trtc.io/usersig),
   pilih `SDKAppID`, isi `UserID`, lalu klik **Generate**. Pakai `UserID` dan
   UserSig yang sama sebagai pasangan pada `connectTencent(userID:userSig:)`.
   Jangan commit UserSig hasil console ke repo; UserSig punya masa berlaku.
   Untuk produksi, backend host harus menerbitkan UserSig bagi nasabah yang
   sudah terautentikasi. `SDKSecretKey` hanya berada di backend.
3. Siapkan `botUserID` Tencent dan proses bot/backend yang menerima pesan C2C
   dari nasabah lalu mengirim balasan sebagai akun bot. SDK ini infra pesan;
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
@Published var pendingTanyaAIDeeplink: URL?

func prepareTanyaAI() {
    let composition = TencentTanyaAIComposition(
        botUserID: AppConfig.tencentBotUserID,
        deeplinkScheme: "ocbcid",
        deeplinkHost: "mobile"
    )
    tanyaAIHost = composition.makeHost(theme: .host) { [weak self] url in
        self?.pendingTanyaAIDeeplink = url
    }
}

func connectTencent(userID: String, userSig: String) {
    TencentChatLifecycle.shared.login(userID: userID, userSig: userSig) { [weak self] result in
        DispatchQueue.main.async {
            guard let self else { return }
            switch result {
            case .success:
                self.isTencentReady = true
            case .failure:
                self.isTencentReady = false
                // Tampilkan retry/error lewat state host app Anda.
            }
        }
    }
}
```

Panggil `prepareTanyaAI()` tepat sebelum `state = .loggedIn`, lalu
`connectTencent` sekali per sesi login yang berhasil setelah mengambil UserSig
dari console (PoC) atau backend (produksi). Bila UserSig kedaluwarsa atau akun
ter-kick, ambil UserSig
baru dan login ulang melalui state aplikasi. Saat logout, kosongkan
`tanyaAIHost`, `isTencentReady`, dan `pendingTanyaAIDeeplink`, lalu panggil
`TencentChatLifecycle.shared.logout(completion:)`. Tunggu callback logout
sebelum login Tencent dengan akun berikutnya. Menutup layar TanyaAI **tidak**
memanggil logout SDK.

### MainCoordinator: tap entry point baru membuka chat

`MainCoordinator` tetap anak RootScreen. Pasang `.tanyaAIHost(host)` pada root
`NavigationView` di Main, dan panggil `present()` hanya saat tombol ditekan:

```swift
@EnvironmentObject var appState: AppState

var body: some View {
    Group {
        if let host = appState.tanyaAIHost {
            mainContent.tanyaAIHost(host)
        } else {
            mainContent
        }
    }
    .onChange(of: appState.pendingTanyaAIDeeplink) { url in
        guard let url else { return }
        appState.pendingTanyaAIDeeplink = nil
        // Panggil method deeplink host yang sudah ada di Main.
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

`TanyaAIHost` menutup fitur sebelum callback deeplink. Callback hanya menaruh
URL di `AppState`; `MainCoordinator` yang menjalankan router existing, sesuai
batas navigasi host Anda. Gunakan URL `https` atau scheme/host lain hanya bila
memang didaftarkan dalam `TanyaAIHost` dan diizinkan router host.

### Apa yang terjadi saat chat dibuka

Package memanggil `makeSession` (instance **baru** setiap presentasi), lalu
`connect()`. Adapter memasang listener, mengambil history C2C, mengirim
`.history` dan `.connected`. Saat nasabah menekan kirim, package memanggil
`send(text:...)`; adapter mengirim pesan ke `botUserID`. Balasan C2C dari bot
diterjemahkan menjadi tiga event `messageStarted`, `messageDelta`, dan
`messageCompleted`. Saat chat ditutup, adapter hanya melepas listener. Login
Tencent tetap hidup sampai logout host. Tidak ada greeting otomatis.

## Batas PoC ini

- Jalur yang ditulis sekarang adalah **teks biasa**. `context` dan
  `requestIdentifier` belum dikirim ke Tencent karena backend belum menyepakati
  format metadata. Jangan menyisipkannya ke teks yang terlihat.
- Bubble bertipe, suggestions, typing, dan deeplink dari bot memerlukan
  kontrak payload bot yang disepakati. Adapter ini tidak menebak JSON yang
  dikirim bot. Definisikan custom message sesuai `docs/BUBBLE_SCHEMA.md`,
  kemudian petakan ke event `TanyaAIChatSession` bila PoC mencakup fitur itu.
- Tidak ada E2E tanpa SDK terpasang, UserSig yang valid, akun bot, dan proses
  backend yang menjawab pesan. Verifikasi akhir perlu dilakukan di host app
  dengan dua akun Tencent. File contoh ini bukan target build repo sandbox.

Referensi API: [integrasi SDK iOS](https://trtc.io/document/34307),
[Swift V2TIMManager](https://im.sdk.qcloud.com/doc/en/swift_V2TIMManager.html),
[pesan dan history](https://im.sdk.qcloud.com/doc/en/swift_V2TIMManager%2BMessage.html).
