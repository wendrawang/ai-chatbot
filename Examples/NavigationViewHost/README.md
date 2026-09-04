# Integrasi Tanya AI ke app existing berbasis NavigationView

Contoh siap-salin untuk host yang layar utamanya SwiftUI `NavigationView`
dan lifecycle-nya `AppDelegate` + `SceneDelegate` — pola yang sama dengan
`LegacyRootScreen` di sandbox ini.

Ada dua tingkat. Mulai dari `Minimal/`, naik ke `Production/` saat menyiapkan
rilis. Keduanya memakai jalur integrasi yang sama; `Production/` hanya
menambahkan hal-hal yang tidak boleh hilang di aplikasi sungguhan.

| | [`Minimal/`](Minimal) | [`Production/`](Production) |
| --- | --- | --- |
| Tujuan | Membuat fitur jalan hari ini | Siap rilis |
| Transport | Membungkus streaming client existing | `URLSessionDataDelegate` sendiri + forwarding pinning |
| Otorisasi | Panggil API otorisasi existing | Sama, plus pengecekan kedaluwarsa dan status `.processing` |
| Theme | `.sandbox` sementara | Pemetaan design token host |
| Presentasi | Presenter kecil yang mem-present controller | Presenter penuh, layar legacy tidak kenal Tanya AI |
| Composition | 5 baris di `SceneDelegate` | Composition root milik scene |

Yang Anda tulis sendiri di versi minimal: dua adapter tipis, lima baris di
`SceneDelegate`, dan satu modifier di layar yang sudah ada. Sisanya di folder
ini adalah placeholder untuk tipe yang **sudah** Anda punya — di project asli
tidak perlu dibuat, langsung panggil kelas networking dan otorisasi existing.

File di sini bukan bagian dari target sandbox. Salin ke project Anda, lalu
ganti nama tipe `Minimal*`/`Host*` dan placeholder `App*` dengan milik Anda.

## Prasyarat

1. **Deployment target minimal iOS 15.** Navigasi internal fitur ini memakai
   `UINavigationController`, bukan `NavigationStack`, jadi tidak ada syarat
   iOS 16. `NavigationView` di app Anda tetap dipakai apa adanya — tidak perlu
   dimigrasi.
2. Tambahkan paket lokal `Packages/TanyaAI` ke project, lalu link produk
   **`TanyaAI`** ke target app. Tambahkan **`TanyaAIDesignSystem`** juga kalau
   memakai `.sandbox` versi minimal. `TanyaAITestSupport` hanya untuk target
   test — jangan pernah ikut ke Release.

## Minimal

Tiga file, dan hanya dua yang benar-benar kode Anda:

| File | Isi |
| --- | --- |
| `MinimalTanyaAITransport.swift` | Meneruskan request ke streaming client existing, meneruskan potongan mentah balik |
| `MinimalTanyaAIAuthorization.swift` | Memanggil API otorisasi existing dengan PIN |
| `MinimalHostIntegration.swift` | Lima baris di scene, satu `@State` dan satu modifier di layar |

Syarat versi ini: **layer networking Anda sudah bisa streaming**. Kalau belum,
lompat ke transport versi `Production/` — `dataTask(with:completionHandler:)`
menahan seluruh respons sampai selesai, jadi semua bubble baru muncul
sekaligus di akhir dan efek streaming-nya hilang.

`.sandbox` dipakai supaya fitur langsung tampil dengan warna yang masuk akal.
Ganti sebelum rilis.

## Production

Tambahan di atas versi minimal:

| File | Kenapa perlu |
| --- | --- |
| `HostTanyaAIStreamingTransport.swift` | SSE di atas `URLSessionDataDelegate`, meneruskan `URLAuthenticationChallenge` ke pinning validator host, cancel yang aman sebelum task jalan, `invalidateAndCancel()` di `deinit` |
| `HostTanyaAIAuthorizationService.swift` | Tolak challenge yang kedaluwarsa, bedakan `.completed` dan `.processing` |
| `HostTanyaAITheme.swift` | Pemetaan warna dan font design system host |
| `HostTanyaAIComposition.swift` | Composition root, dibuat sekali per scene |
| `HostTanyaAIPresenter.swift` | Layar legacy cukup kenal protokol, bukan Tanya AI |
| `HostRootScreen.swift` | Layar root dan layar detail yang memicu lewat presenter |
| `HostSceneDelegate.swift` | Perakitan di scene |

Detail kontrak yang perlu dipatuhi transport:

- Paket mengirim `path` relatif, `body` JSON
  (`{"message": "...", "conversationIdentifier": "..."}`), dan
  `requestIdentifier`. Host yang menambahkan base URL, header, token, tracing.
- Header yang diharapkan backend: `POST`, `Accept: text/event-stream`,
  `Content-Type: application/json`.
- Teruskan potongan respons **mentah** ke `onData`. Paket yang memotong SSE-nya
  sendiri — jangan di-buffer atau di-decode di host.
- Callback boleh datang dari queue mana pun; ViewModel di paket sudah hop ke
  main queue sendiri.
- Event yang dipahami paket: `response.started`, `text.delta`, `content.*`,
  `response.suggestions`, `response.completed`. Skema lengkapnya ada di README
  utama bagian *Response lifecycle*.

Untuk otorisasi: kembalikan `.completed` kalau transaksi tuntas, `.processing`
kalau masih diproses backend — bubble approval menampilkan status berbeda. PIN
tidak boleh masuk log, analytics, crash report, clipboard, atau storage.

## Host SwiftUI yang bukan root

`Minimal/` dan `Production/` sama-sama memanggil `attach(rootController:)`
dari `SceneDelegate`. Itu hanya berlaku kalau layar yang mem-present **adalah**
root window.

Kebanyakan aplikasi tidak begitu. Coordinator utamanya muncul setelah login,
di dalam tab, atau di tengah stack — dan sebuah `View` SwiftUI tidak punya
`UIViewController` sendiri untuk dijadikan tempat present.

`SwiftUIHost/` menutup celah itu. `TanyaAIHostAnchor` menaruh satu controller
kosong berukuran nol di hierarki, semata supaya presenter punya pegangan;
UIKit lalu naik ke controller terdekat yang bisa mem-present, yaitu layar yang
sedang dilihat nasabah.

```swift
struct MainCoordinator: View {
    let presenter: HostTanyaAIPresenter

    var body: some View {
        NavigationView { ... }
            .navigationViewStyle(StackNavigationViewStyle())
            .tanyaAIHost(presenter)          // <- satu baris
    }
}
```

Membuka fitur jadi `presenter.presentTanyaAI()`, bukan menyetel flag.

### Kenapa ini menghapus `isShowTanyaAI` dan `pendingDeeplink`

Keduanya bukan state layar.

Apakah fitur sedang tampil adalah milik presenter — layar tidak perlu
menyimpan salinannya yang bisa melenceng. Dan urutan hand-off deeplink adalah
*completion* dari dismissal, bukan variabel kedua yang harus dijaga tetap
sinkron:

```swift
// sebelum — dua @State, urutannya diatur lewat onDismiss
pendingDeeplink = url
isShowTanyaAI = false

// sesudah — urutannya adalah completion-nya
presenter.dismissTanyaAI {
    DeeplinkManager.instance.openUrlScheme(url)
}
```

`HostDeeplinkBridge` sudah membungkus pola ini, termasuk kasus deeplink yang
datang saat fitur **tidak** sedang tampil.

### Yang sudah diverifikasi

Berbeda dari file contoh lain di folder ini, `SwiftUIHost/` di-type-check
terhadap paket sungguhan, dan polanya dijalankan lewat UI test deeplink
sandbox — present, hand-off, dismissal beserta completion-nya, sampai
destinasi ter-push. Jadi ini bukan sekadar sketsa.

## Yang tidak boleh

- Menjadikan Tanya AI sebagai `NavigationLink` destination.
- Mem-push fitur ke `UINavigationController` legacy; present sebagai
  controller tersendiri supaya navigasi keduanya tidak bercampur.
- Push `UIHostingController` fitur ke `UINavigationController` existing.
- Menyimpan hasil `TanyaAIModule.makeViewController` sebagai singleton — panggil ulang
  tiap presentasi supaya tiap sesi dapat graph baru.
- Membuat `TanyaAIDependencies` di dalam `body`.
- Menaruh sertifikat, token, atau host internal di dalam paket.

## Verifikasi setelah integrasi

1. Buka Tanya AI dari layar detail, tutup lagi — posisi navigasi dan state
   lokal layar detail harus utuh.
2. Buka–tutup 10 kali sambil merekam Instruments Allocations; tidak boleh ada
   generation yang terus tumbuh.
3. Putus koneksi di tengah stream — error banner muncul, tidak crash.
4. Salah PIN lalu benar; pastikan tidak ada PIN yang muncul di log.

## Deeplink hand-off

Tombol di bubble (atau `handoff` pada konfirmasi) menyerahkan navigasi ke
aplikasi Anda. Backend mengirim deeplink utuh sebagai satu string, misalnya
`ocbcid://mobile?type=transfer`.

### Siapa menulis apa

| Lapisan | Tanggung jawab | Perlu Anda kerjakan? |
| --- | --- | --- |
| Backend | Kirim `content.actions`, atau `handoff` di konfirmasi, berisi string deeplink | Ya — di sisi server |
| Paket / SDK | Render tombolnya, laporkan deeplink lewat `onAction`. Tidak parsing, tidak membuka, tidak menutup dirinya | **Tidak ada.** Sudah tersedia |
| App Anda | Cek link ini milik app Anda, tunggu fitur tertutup, lalu serahkan ke deeplink handler yang sudah ada | Ya — dan itu saja |

Yang **tidak** perlu Anda tulis ulang: parsing `type`, pemetaan ke layar, dan
kembali ke dashboard. Deeplink handler existing Anda sudah melakukannya —
hand-off ini cuma memberi URL ke handler itu pada saat yang tepat.

Validasinya sengaja hanya dua baris: **scheme** dan **host**. Scheme yang
menolak `https://…`, `tel:`, dan link yang akan membuka app lain; host
mengikat link ke entry point deeplink Anda. Sisanya urusan handler existing —
parser kedua di sini hanya akan menyimpang dari yang asli.

### Dua tingkat

| | [`Deeplink/Minimal`](Deeplink/Minimal) | [`Deeplink/Production`](Deeplink/Production) |
| --- | --- | --- |
| Bentuk | Satu file, dua `@State` di layar root | Objek `HostDeeplinkBridge` tersendiri |
| Jalur | Panggil handler existing langsung | Round-trip lewat `UIApplication.open`, masuk lagi via `scene(_:openURLContexts:)` |
| Cold start | Tidak ditangani | Ditangani (`onAppear`/`onChange`) |
| Entry point | Hanya hand-off | Satu entry point untuk semua sumber deeplink |

Mulai dari `Minimal/`. Isinya benar-benar cuma ini:

```swift
private func handle(_ action: TanyaAIAction) {
    guard let url = URL(string: action.deeplink),
          url.scheme == "ocbcid",
          url.host == "mobile" else {
        return
    }
    let controller = activeController
    activeController = nil
    controller?.dismiss(animated: true) {
        AppDeeplinkHandler.open(url)   // handler existing Anda
    }
}
```

### Tiga hal yang menentukan berhasil-tidaknya

- **Deeplink ditahan dulu, jangan langsung dibuka.** Fitur tampil full screen;
  navigasi yang terjadi di bawahnya akan hilang.
- **Fitur tidak menutup dirinya sendiri.** Host yang menutup.
- **Serahkan URL dari completion `dismiss(animated:completion:)`,** bukan
  tepat setelah memanggil dismiss — saat itu modalnya masih beranimasi.

Kalau handler existing Anda **tidak** otomatis kembali ke dashboard, lakukan itu di dalam completion dismiss — sebelum membuka destinasi. Versi sandbox (`TanyaAISandboxApp/SandboxDeeplinkRouter.swift`) memperlihatkan pola itu, karena sandbox tidak punya deeplink handler sendiri.

Round-trip lewat `UIApplication.open` di versi Production membuat hand-off
memakai jalur yang sama dengan push notification atau app lain — daftarkan
scheme-nya di `CFBundleURLTypes`. Kalau round-trip tidak memberi keuntungan,
panggil handler-nya langsung seperti versi minimal.

### Menguji hand-off tanpa backend

Tiga lapis, dari yang paling murah:

**1. Deeplink handler Anda sendiri, tanpa Tanya AI.** Pastikan dulu URL-nya
memang membuka layar yang benar:

```sh
xcrun simctl openurl booted "ocbcid://mobile?type=transfer&amount=1250000"
```

Kalau ini saja tidak jalan, hand-off pasti tidak jalan. Penyebab paling
sering: scheme belum terdaftar di `CFBundleURLTypes`, sehingga
`UIApplication.open` gagal diam-diam tanpa error.

**2. Handler-nya saja, sebagai unit test.** `handle(_:)` menerima
`TanyaAIAction` biasa, jadi tidak perlu UI:

```swift
func testHandOffOpensTheAppsOwnDeeplink() {
    var opened: [URL] = []
    let bridge = HostDeeplinkBridge(
        presenter: presenter,
        dispatch: { _ in },
        open: { opened.append($0) }
    )

    bridge.handle(
        TanyaAIAction(
            identifier: "open-transfer",
            deeplink: "ocbcid://mobile?type=transfer"
        )
    )
    bridge.handle(
        TanyaAIAction(
            identifier: "phishing",
            deeplink: "https://example.com/promo"
        )
    )

    XCTAssertEqual(opened.map(\.absoluteString), [
        "ocbcid://mobile?type=transfer"
    ])
}
```

Dua assertion sekaligus: yang benar diteruskan, yang bukan milik app Anda
tidak.

**3. Alur penuh di simulator, dengan stream palsu.** Arahkan mock transport ke
deeplink Anda sendiri:

```swift
let transport = MockTanyaAIStreamingTransport(
    scenario: .custom(
        MockTanyaAIActionFixture.actionCardChunks(
            buttons: [
                .init(
                    title: "Open transfer",
                    deeplink: "ocbcid://mobile?type=transfer",
                    identifier: "open-transfer"
                ),
                .init(
                    title: "Blocked link",
                    style: "secondary",
                    deeplink: "https://example.com/promo",
                    identifier: "blocked"
                )
            ]
        )
    )
)
```

Butuh `import TanyaAITestSupport` — target debug/test saja, jangan ikut ke
Release. Untuk menguji jalur kedua (konfirmasi yang hand-off, bukan kartu
aksi) pakai `MockTanyaAIActionFixture.approvalHandoffChunks(deeplink:)`; PIN
sheet tidak boleh muncul sama sekali.

Tombolnya bisa ditekan dari UI test lewat `action.<identifier>`, misalnya
`app.buttons["action.open-transfer"]`.

Yang layak dipastikan saat run pertama:

1. Tanya AI benar-benar tertutup sebelum navigasi terjadi.
2. Layar tujuan muncul, dan tombol back-nya menunjuk dashboard — bukan
   menumpuk di atas layar sebelumnya.
3. Tombol `https` tidak melakukan apa pun, dan fitur tetap terbuka.
