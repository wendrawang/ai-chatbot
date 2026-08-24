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
| App Anda | Validasi deeplink, buka/rutekan, tutup fitur, kembali ke dashboard, push destinasi | Ya — ini seluruh pekerjaannya |

Di sisi app, konkretnya cuma tiga hal:

1. **Satu handler** di `TanyaAIModule.makeView(onAction:)`.
2. **Satu validasi** — kalau deeplink handler existing Anda sudah punya
   parser, panggil itu; jangan bikin parser kedua.
3. **Satu urutan** tutup → dashboard → push, di layar root.

### File contoh

| File | Isi |
| --- | --- |
| `HostDeeplinkBridge.swift` | `handle(_:)` validasi + buka, `receive(_:)` entry point deeplink, `deliverPendingDestination()` push saat layar sudah bersih, `validate(_:)` batas keamanannya |
| `HostDeeplinkRootScreen.swift` | Urutan tutup → kembali ke dashboard → push destinasi |

### Empat hal yang menentukan berhasil-tidaknya

- **Validasi sebelum membuka.** String-nya datang dari stream, jadi
  perlakukan seperti input tidak tepercaya: cek scheme (ini yang menolak
  `https`, `tel:`, dan link ke app lain), cek host entry point, cek tujuannya
  ada di allowlist. Tanpa itu, respons bisa mengarahkan app Anda ke mana saja.
- **Fitur tidak menutup dirinya sendiri.** Host yang menutup, karena presentasi
  full screen tidak bisa mem-push apa pun di bawahnya.
- **Destinasi dikirim dari `onDismiss`,** bukan tepat setelah binding di-set
  `false` — saat itu cover masih beranimasi.
- **Pop dan push jangan di tick yang sama.** `NavigationView` membuang push
  yang dimulai saat pop masih beranimasi; beri jeda selama animasi pop.

Satu kasus yang mudah terlewat: deeplink yang datang saat tidak ada apa pun
yang ter-present — cold start, atau notifikasi ditekan dari dashboard — tidak
punya dismissal untuk ditunggu. Kirim langsung, jangan menunggu `onDismiss`
yang tidak akan pernah datang.

Round-trip lewat `UIApplication.open` membuat hand-off memakai jalur deeplink
yang sama dengan push notification atau app lain — daftarkan scheme-nya di
`CFBundleURLTypes`. Kalau round-trip tidak memberi keuntungan, panggil
`receive(url)` langsung; sisanya identik.
