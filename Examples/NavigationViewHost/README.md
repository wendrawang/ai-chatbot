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
| Presentasi | `@State` + `fullScreenCover` | Presenter observable, layar legacy tidak kenal Tanya AI |
| Composition | 5 baris di `SceneDelegate` | Composition root milik scene |

Yang Anda tulis sendiri di versi minimal: dua adapter tipis, lima baris di
`SceneDelegate`, dan satu modifier di layar yang sudah ada. Sisanya di folder
ini adalah placeholder untuk tipe yang **sudah** Anda punya — di project asli
tidak perlu dibuat, langsung panggil kelas networking dan otorisasi existing.

File di sini bukan bagian dari target sandbox. Salin ke project Anda, lalu
ganti nama tipe `Minimal*`/`Host*` dan placeholder `App*` dengan milik Anda.

## Prasyarat

1. **Deployment target minimal iOS 16.** Paket memakai `NavigationStack`,
   `presentationDetents`, dan `.toolbar(.hidden, for:)`. Ini blocker keras.
   `NavigationView` di app Anda tetap boleh dipakai — tidak perlu ikut
   dimigrasi ke `NavigationStack`.
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
| `HostRootScreen.swift` | Penempatan `fullScreenCover` dan layar detail yang memicu lewat presenter |
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

## Yang tidak boleh

- Menjadikan Tanya AI sebagai `NavigationLink` destination.
- Menaruh `fullScreenCover` di layar detail yang bisa ke-pop; taruh di
  boundary stabil di luar `NavigationView`.
- Push `UIHostingController` fitur ke `UINavigationController` existing.
- Menyimpan hasil `TanyaAIModule.makeView` sebagai singleton — panggil ulang
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
    pendingDeeplink = url      // ditahan dulu
    showsTanyaAI = false       // tutup fitur
}

private func openPendingDeeplink() {   // dipanggil dari onDismiss
    guard let url = pendingDeeplink else { return }
    pendingDeeplink = nil
    AppDeeplinkHandler.open(url)       // handler existing Anda
}
```

### Tiga hal yang menentukan berhasil-tidaknya

- **Deeplink ditahan dulu, jangan langsung dibuka.** Fitur tampil full screen;
  navigasi yang terjadi di bawahnya akan hilang.
- **Fitur tidak menutup dirinya sendiri.** Host yang menutup.
- **Serahkan URL dari `onDismiss`,** bukan tepat setelah binding di-set
  `false` — saat itu cover masih beranimasi.

Kalau handler existing Anda **tidak** otomatis kembali ke dashboard, pop dulu
di `onDismiss`, lalu serahkan URL-nya setelah animasi pop selesai —
`NavigationView` membuang push yang dimulai saat pop masih berjalan. Versi
sandbox (`TanyaAISandboxApp/LegacyRootScreen.swift`) memperlihatkan pola itu,
karena sandbox tidak punya deeplink handler sendiri.

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
