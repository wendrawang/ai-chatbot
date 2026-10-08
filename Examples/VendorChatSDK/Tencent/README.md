# PoC Tencent Chat untuk host Tanya AI

Ini contoh **host-side**, bukan perubahan pada package TanyaAI. Salin seluruh file
Swift pada root folder ini ke target host app (empat file; folder `Tests` tidak ikut). Contoh memakai **Tencent Chat Core SDK
edisi Swift** (`ImSDK_Plus_Swift`) dan **group chat** dengan satu `groupID`
untuk percakapan nasabah, bot, dan agent bila diperlukan. Jangan pasang TUIKit
bila UI chat tetap memakai TanyaAI.
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
3. Backend menyiapkan group **Public** dengan `ApplyJoinOption: DisableApply`
   dan `InviteJoinOption: DisableInvite`; nasabah dan bot ditambahkan sebagai anggota
   oleh backend. Akun PoC tetap `wen` dan `bot_poc` pada
   SDKAppID yang sama. Kirim **GroupId mentah** ke host, bukan conversation ID
   dengan prefix `group_`. Adapter tidak membuat group atau memanggil `joinGroup`.
4. Gunakan group terpisah untuk setiap percakapan/nasabah. Untuk New chat,
   backend membuat group baru dan host menggunakan GroupId baru tersebut;
   membuka ulang percakapan memakai GroupId yang sama. Jangan gunakan
   `AVChatRoom` untuk fitur ini karena tidak menyediakan history seperti group biasa.
5. Bot/backend menerima pesan group lalu membalas ke group yang sama. Login
   dan `sendMessage` saja tidak menghasilkan respons AI. Contoh ini mengambil
   20 pesan group terakhir; pagination dan daftar sesi merupakan kebijakan host/backend.

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
host yang stabil. `AppConfig.tencentGroupID` merupakan konfigurasi PoC; untuk
produksi gunakan GroupId dari backend setelah membership disiapkan. Setelah login host berhasil dan pasangan `userID`/UserSig
Tencent tersedia, jalankan `connectTencent`:

```swift
@Published private(set) var isTencentReady = false
@Published private(set) var tanyaAIHost: TanyaAIHost?
@Published private(set) var pendingChatDeeplink: URL?
@Published private(set) var tencentLoginError: Error?

func prepareTanyaAI(theme: TanyaAITheme = .sandbox) {
    guard tanyaAIHost == nil else { return }
    let composition = TencentTanyaAIComposition(
        groupID: AppConfig.tencentGroupID,
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
`connect()`. Adapter memasang listener dan mengambil history melalui
`getGroupHistoryMessageList(groupID:...)`, lalu mengirim `.history` dan `.connected`.
Saat nasabah menekan kirim, adapter memakai `sendMessage(receiver: nil, groupID:...)`.
Listener dan history hanya menerima `message.groupID` yang cocok. Pesan sendiri
pada live diabaikan karena prompt sudah ditampilkan lokal; pesan sendiri pada history
menjadi customer. Pesan bot/agent menjadi assistant. Satu group ini berisi satu nasabah dan bot/agent;
UI ini tidak memetakan nasabah lain sebagai peserta terpisah. Group tips tanpa text/custom
body tidak menjadi bubble. Pemetaan custom bubble tetap sama dengan versi C2C.

Saat layar ditutup, adapter hanya melepas listener dan membersihkan buffer; tidak
logout SDK, keluar group, atau menghapus group. SDK logout tetap milik AppState.
Tidak ada greeting/initial prompt otomatis. Greeting server adalah pesan group biasa.
History C2C lama tetap pada conversation lama; group baru mempunyai history sendiri.

## Uji group dan balasan bot tanpa backend AI

Gunakan SDKAppID yang sama untuk akun `wen`, akun `bot_poc`, dan group.
Dari mesin yang dapat menjangkau Tencent, pilih GroupId PoC, misalnya
`tanyaai_wen_poc`, lalu buat group tertutup keanggotaan **sekali**:

```sh
TENCENT_GROUP_ID='tanyaai_wen_poc' \
TENCENT_SDK_APP_ID='SDKAppID_ANDA' \
TENCENT_REST_HOST='adminapiidn.im.qcloud.com' \
sh Examples/VendorChatSDK/Tencent/send_test_reply.sh create-group
```

Script memanggil `v4/group_open_http_svc/create_group` dengan body:

```json
{
  "Owner_Account": "wen",
  "Type": "Public",
  "ApplyJoinOption": "DisableApply",
  "InviteJoinOption": "DisableInvite",
  "GroupId": "tanyaai_wen_poc",
  "Name": "Chat PoC",
  "MemberList": [{ "Member_Account": "bot_poc" }]
}
```

Owner dan anggota awal otomatis ditambahkan pada group non-AVChatRoom.
Contoh memilih Public agar group langsung aktif; Work/Private memerlukan pesan
pertama owner sebelum aktif. Permohonan join dan undangan melalui SDK dimatikan;
backend/admin mengelola membership melalui REST. Akun harus sudah ada;
set `TENCENT_USER_ID`/`TENCENT_BOT_ID` untuk mengganti akun PoC. Gunakan GroupId
hasil respons di `TencentTanyaAIComposition(groupID:...)`. Bila group sudah ada,
jangan jalankan create lagi; pastikan membership nasabah dan bot sudah benar.
Domain contoh di atas untuk region Jakarta; sesuaikan dengan region SDKAppID.

Setelah host login sebagai `wen` dan layar Tanya AI dibuka, kirim balasan uji:

```sh
TENCENT_GROUP_ID='tanyaai_wen_poc' \
TENCENT_SDK_APP_ID='SDKAppID_ANDA' \
TENCENT_REST_HOST='adminapiidn.im.qcloud.com' \
sh Examples/VendorChatSDK/Tencent/send_test_reply.sh answer
```

Endpoint adalah `v4/group_open_http_svc/send_group_msg`. Body memakai `GroupId`,
`From_Account = bot_poc`, `Random`, `OnlineOnlyFlag = 0`, dan `MsgBody` dari fixture.
Tidak ada `To_Account`, `SyncOtherMachine`, atau `MsgRandom` C2C. Semua anggota group
menerima pesan ini. Akun bot harus merupakan anggota group.

Script meminta UserSig **app admin** (`administrator` secara default); bukan
UserSig `wen` atau `bot_poc`. Ganti `TENCENT_ADMIN_ID` bila akun admin berbeda.
SDKAppID wajib, secret key tidak dikirim oleh script. Periksa `ActionStatus: OK`
dan `ErrorCode: 0`, bukan HTTP 200 saja. `curl` modern dan Python 3 diperlukan.
Argumen payload: `text`, `radio`, `info`, `link`, `confirmation`, atau `answer`.

Untuk memeriksa JSON tanpa mengirim request atau memasukkan kredensial:

```sh
TENCENT_GROUP_ID='tanyaai_wen_poc' TENCENT_DRY_RUN=1 \
sh Examples/VendorChatSDK/Tencent/send_test_reply.sh answer
```

Alternatifnya, login `bot_poc` di proses/device lain lalu kirim pesan ke group yang
sama. Jangan mengganti login nasabah pada proses host yang sedang diuji.
Jika Mac kantor memblokir Tencent, jalankan REST dari mesin/backend yang punya akses.

## Bot otomatis dan sesi baru

Gunakan webhook
[Group.CallbackAfterSendMsg](https://www.tencentcloud.com/document/product/1047/34375).
Backend memeriksa `GroupId`, memproses pesan nasabah, dan mengirim respons ke GroupId
itu melalui `send_group_msg` dengan `From_Account = bot_poc`. Abaikan pesan yang
berasal dari bot/agent untuk mencegah respons berulang, dan deduplikasi callback.
Kontrak TIMTextElem/TIMCustomElem tetap sesuai [TENCENT_MESSAGE_CONTRACT.md](../../../docs/TENCENT_MESSAGE_CONTRACT.md).

Group baru memberikan pemisahan conversation/history Tencent, tetapi backend tetap
harus memisahkan konteks AI berdasarkan GroupId. Greeting dipicu lewat pembukaan
sesi backend; `initialPrompt` adalah prompt nasabah yang terlihat, bukan sinyal tersembunyi.
Contoh ini memakai group yang sudah disiapkan sebelum host dibuat. Tombol New chat,
backend provisioning, daftar history lintas group, dan lifecycle arsip group belum
merupakan fitur otomatis dalam package TanyaAI.

Referensi: [create group](https://www.tencentcloud.com/document/product/1047/34895),
[send group message](https://trtc.io/document/34959),
[group history](https://www.tencentcloud.com/document/product/1047/47998),
[perbedaan tipe group dan aktivasi](https://trtc.io/document/33529?product=chat).
Jika agent ditambahkan setelah chat dimulai dan perlu membaca pesan lama, atur
akses history sebelum join pada console/backend; Public default tidak membukanya.

## Custom bubble dan kontrak terbaru

Adapter membaca `TIMTextElem` serta seluruh rantai `TIMCustomElem` untuk live dan
history. Update DesignKit/TanyaAI bersama dan salin **seluruh** file Swift folder
ini, termasuk `TencentChatSessionAdapter+Contract.swift`. Kontrak `Data`, aturan
radio terbaru, callback `destination_type`, dan handoff PIN dijelaskan lengkap
di [TENCENT_MESSAGE_CONTRACT.md](../../../docs/TENCENT_MESSAGE_CONTRACT.md).

Jalankan `sh send_test_reply.sh answer` untuk kombinasi teks/radio/kartu/link.
Argumen lainnya: `text`, `radio`, `info`, `link`, `confirmation`.
Script membutuhkan Python 3; sender default `bot_poc`, target wajib `TENCENT_GROUP_ID`.

## Batas PoC ini

- `context`/`requestIdentifier` belum dikirim sebagai metadata Tencent; kontrak
  backend harus menetapkan jalurnya. Teks radio menggunakan label sebagai prompt;
  `value` dipertahankan sebagai ID pilihan.
- History tetap 20 pesan group terakhir. Pagination membutuhkan backend/host policy.
- Bila history gagal, contoh memulihkan batch kosong; kegagalan send SDK diteruskan
  sebagai `.failed`. Pastikan group/membership sudah disiapkan sebelum presentasi.
- Konfirmasi baru mengirim confirmation ID/fields ke flow PIN host, tanpa
  memalsukan challenge atau menjalankan transaksi di package.
- Runtime Tencent/login dan pengiriman REST tetap diuji pada host/device Anda.

Referensi API: [integrasi SDK iOS](https://trtc.io/document/34307),
[Swift V2TIMManager](https://im.sdk.qcloud.com/doc/en/swift_V2TIMManager.html),
[pesan dan history](https://im.sdk.qcloud.com/doc/en/swift_V2TIMManager%2BMessage.html).


## Pemeriksaan offline

```sh
sh Scripts/test_tencent_group_adapter.sh
python3 -m unittest discover -s Examples/VendorChatSDK/Tencent/Tests -p 'test_*.py' -v
```

Runner Swift memakai contracts asli dan SDK double terisolasi untuk memeriksa routing,
history, self echo, duplikasi, buffering, error send, serta pelepasan listener. Tidak ada
runtime Tencent di runner ini. File root Swift juga harus typecheck terhadap framework
Tencent asli sesuai versi host; validasi perubahan ini memakai 9.1.7818 pada target iOS 15.
Tes Python memeriksa envelope, endpoint, payload dan respons REST dengan curl double;
tidak mengirim pesan atau membuat group nyata. Folder `Tests` tidak dimasukkan ke target host.
