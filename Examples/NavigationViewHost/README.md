# Integrasi Tanya AI ke app existing berbasis NavigationView

Contoh siap-salin untuk host yang layar utamanya SwiftUI `NavigationView`
dan lifecycle-nya `AppDelegate` + `SceneDelegate` — pola yang sama dengan
`LegacyRootScreen` di sandbox ini.

File di folder ini bukan bagian dari target sandbox. Salin ke project Anda,
lalu ganti nama tipe `Host*` dan placeholder `App*` dengan milik Anda.

## Prasyarat

1. **Deployment target minimal iOS 16.** Paket memakai `NavigationStack`,
   `presentationDetents`, dan `.toolbar(.hidden, for:)`. Ini blocker keras.
   `NavigationView` di app Anda tetap boleh dipakai — tidak perlu ikut
   dimigrasi ke `NavigationStack`.
2. Tambahkan paket lokal `Packages/TanyaAI` ke project, lalu link **produk
   `TanyaAI`** saja ke target app. `TanyaAITestSupport` hanya untuk target
   test — jangan pernah ikut ke Release.

## Langkah

| # | Yang dikerjakan | File contoh |
| --- | --- | --- |
| 1 | Adapter streaming ke networking existing | `HostTanyaAIStreamingTransport.swift` |
| 2 | Adapter otorisasi PIN ke secure API existing | `HostTanyaAIAuthorizationService.swift` |
| 3 | Mapping design token ke `TanyaAITheme` | `HostTanyaAITheme.swift` |
| 4 | Composition root, dibuat sekali per scene | `HostTanyaAIComposition.swift` |
| 5 | Presenter observable untuk memicu presentasi | `HostTanyaAIPresenter.swift` |
| 6 | Pasang `fullScreenCover` di luar `NavigationView` | `HostRootScreen.swift` |
| 7 | Rakit semuanya di scene | `HostSceneDelegate.swift` |

### 1. Streaming transport

Paket mengirim `TanyaAIStreamRequest` berisi `path` relatif, `body` JSON
(`{"message": "...", "conversationIdentifier": "..."}`), dan
`requestIdentifier`. Tugas host: mengubahnya jadi `URLRequest` bersama base
URL, header, token, dan tracing, lalu meneruskan **potongan mentah** respons
ke `onData` apa adanya. Paket yang memotong SSE-nya sendiri, jadi jangan
di-buffer atau di-decode di host.

Header yang diharapkan backend: `Accept: text/event-stream`,
`Content-Type: application/json`, method `POST`.

Dua hal yang sering salah:

- **Jangan pakai `dataTask(with:completionHandler:)`** — itu menahan seluruh
  respons sampai selesai, jadi tidak ada streaming. Harus delegate API
  (`URLSessionDataDelegate`), seperti di contoh.
- **Jangan bikin `URLSession` baru tanpa pinning Anda.** Contoh ini meneruskan
  `URLAuthenticationChallenge` ke validator existing lewat
  `HostTanyaAISecurityDelegate`. Kalau layer networking Anda sudah punya
  streaming sendiri (mis. Alamofire `streamRequest` atau SSE client internal),
  bungkus itu saja dan buang kelas contohnya.

`URLSession` menahan delegate-nya sampai di-invalidate, jadi contoh ini
memanggil `invalidateAndCancel()` di `deinit`. Kalau Anda memakai session
existing milik host, hapus bagian itu — session-nya bukan milik adapter.

Callback boleh datang dari queue mana pun — ViewModel di paket sudah hop ke
main queue sendiri.

Event SSE yang dipahami paket: `response.started`, `text.delta`,
`content.*`, `response.suggestions`, `response.completed`. Skema lengkapnya
ada di README utama bagian *Response lifecycle*.

### 2. Otorisasi PIN

Paket hanya mengumpulkan digit dan menampilkan hasil. Host yang memegang
eksekusi transaksi, retry, lockout, dan mapping error. Kembalikan
`.completed` kalau transaksi tuntas, `.processing` kalau masih diproses
backend — bubble approval akan menampilkan status berbeda.

PIN tidak boleh masuk log, analytics, crash report, clipboard, atau storage.
Teruskan langsung ke API, jangan disimpan di property.

### 3. Theme

Kalau design system Anda `UIColor`/`UIFont`, konversi di sini dengan
`Color(uiColor:)` dan `Font(uiFont)`. Jangan pernah meng-import design system
host dari dalam paket.

### 4–7. Perakitan

`HostTanyaAIComposition` dibuat **sekali** di `SceneDelegate` lalu diturunkan.
Jangan membuatnya di dalam `body` — itu bikin transport dan authorization
service dibangun ulang tiap render.

Titik paling penting ada di `HostRootScreen`:

```swift
NavigationView { ... }
    .fullScreenCover(isPresented: $presenter.isPresented) {
        TanyaAIModule.makeView(...)
    }
```

`fullScreenCover` menempel di `NavigationView`, bukan di dalamnya, dan bukan
di layar detail yang bisa ke-pop. Layar detail cukup memanggil
`presenter.presentTanyaAI()` — dia tidak perlu tahu Tanya AI sama sekali,
cukup kenal protokol `HostTanyaAIPresenting`.

## Yang tidak boleh

- Menjadikan Tanya AI sebagai `NavigationLink` destination.
- Push `UIHostingController` fitur ke `UINavigationController` existing.
- Menyimpan hasil `TanyaAIModule.makeView` sebagai singleton — panggil ulang
  tiap presentasi supaya tiap sesi dapat graph baru.
- Menaruh sertifikat, token, atau host internal di dalam paket.

## Verifikasi setelah integrasi

1. Buka Tanya AI dari layar detail, tutup lagi — posisi navigasi dan state
   lokal layar detail harus utuh.
2. Buka–tutup 10 kali sambil merekam Instruments Allocations; tidak boleh ada
   generation yang terus tumbuh.
3. Putus koneksi di tengah stream — error banner muncul, tidak crash.
4. Salah PIN lalu benar; pastikan tidak ada PIN yang muncul di log.
