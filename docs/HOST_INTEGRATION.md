# Membuka Tanya AI dari host app

Tanya AI adalah halaman SwiftUI biasa: `TanyaAIHost.makeView()` ditampilkan oleh
navigasi milik host, dan halaman berikutnya juga milik host. Package tidak membuat
modal, animasi, navigation stack, service, atau aturan bisnis sendiri, sehingga
API yang sama dipakai oleh host SwiftUI saat ini maupun aplikasi revamp nanti.

## Package dan font

Tambahkan product `TanyaAI` ke target host. Jika host memanggil API font atau token
secara langsung, tambahkan juga product `DesignKit` dari package yang sama dengan
dependency TanyaAI, agar tidak ada dua salinan package/token/font.

Daftarkan font sekali di `application(_:didFinishLaunchingWithOptions:)`:

```swift
import DesignKit

do { try FontFace.registerFonts() } catch { /* log milik host */ }
```

Font dibaca dari `Bundle.module` DesignKit; host tidak perlu menyalin file font atau
menambahkannya ke `UIAppFonts`. Daftar face ada di
[katalog font](../Packages/DesignKit/Sources/DesignKit/Resources/Fonts/SOURCES.md).

## 1. Host SwiftUI saat ini: coordinator + destination

Tanya AI didaftarkan seperti fitur lain: `NavigationLink(tag:selection:)` di coordinator
yang punya pintu masuk Tanya AI. View model halaman dipegang `@StateObject` di view
tujuan (`TanyaAIDestination`), sehingga dibuat sekali saat halaman di-push, dilepas saat
di-pop, dan tidak ikut dibuat ulang ketika halaman induk render ulang. Halaman dibungkus
base `Screen` host, jadi blocker per halaman dan blocker root tetap tampil di atasnya.

```
Coordinator induk (createNavigationLinks / switch rute)
└── TanyaAICoordinator          ← hanya NavigationLink, tidak membuat view model
    └── TanyaAIDestination      ← @StateObject TanyaAIScreenViewModel
        └── Screen { TanyaAIScreen }   ← host.makeView(onBack:)
```

```swift
// TanyaAICoordinator.swift
struct TanyaAICoordinator: View {
    static let named = String(describing: TanyaAICoordinator.self)
    @Binding var selectionCoordinatorName: String?

    var body: some View {
        NavigationLink(tag: Self.named, selection: $selectionCoordinatorName) {
            TanyaAIDestination(onBack: close)
        } label: { EmptyView() }
        .hidden()
    }

    private func close() {
        guard selectionCoordinatorName == Self.named else { return }
        selectionCoordinatorName = nil
    }
}

// TanyaAIDestination.swift
struct TanyaAIDestination: View {
    @StateObject private var viewModel = TanyaAIScreenViewModel()
    let onBack: () -> Void

    var body: some View {
        Screen { TanyaAIScreen(viewModel: viewModel, onBack: onBack) }
    }
}

// TanyaAIScreen.swift
struct TanyaAIScreen: ScreenContent {
    @ObservedObject var viewModel: TanyaAIScreenViewModel
    let onBack: () -> Void

    var body: some View {
        viewModel.makeHost().makeView(onBack: onBack)
    }
}

// TanyaAIScreenViewModel.swift — konfigurasi lewat init, bukan di body coordinator.
final class TanyaAIScreenViewModel: ScreenContentViewModel {
    // Dibuat sekali bersama view model (@StateObject destination), dipakai ulang setiap render.
    @MainActor
    private(set) lazy var bridge = TanyaAIBridge(
        onNewConversation: { [weak self] in self?.startNewConversation() },
        onSend: { [weak self] text in self?.useCase.send(text) ?? false }
    )

    @MainActor
    func makeHost() -> TanyaAIHost {
        TanyaAIHost(locale: Locale(identifier: Localize.currentLanguage()), welcome: welcome, bridge: bridge)
    }
}
```

Di coordinator induk, daftarkan `TanyaAICoordinator(selectionCoordinatorName: $destinationCoordinatorName)`
bersama link lain (pada host dengan registry lazy, tambahkan entri di dictionary link),
lalu buka dengan `destinationCoordinatorName = TanyaAICoordinator.named`. Contoh lengkap:
[MainCoordinator](../TanyaAISandboxApp/Main/MainCoordinator.swift),
[DetailDestination](../TanyaAISandboxApp/Detail/DetailDestination.swift), dan folder
[TanyaAI sandbox](../TanyaAISandboxApp/TanyaAI).

Yang sengaja tidak dipakai: membungkus `NavigationView` main dengan `UINavigationController`
representable (safe area dan layout main rusak), serta router global yang memilih
halaman aktif (halaman di belakang yang dibangun ulang ikut melapor tampil sehingga
link salah halaman aktif). Akses "dari mana saja" sebaiknya menunggu navigasi revamp.

## 2. Aplikasi revamp dengan navigasi bersih

Package tidak bergantung pada pola di atas; coordinator dan base `Screen` milik host.
Untuk navigasi lain cukup ganti pemanggilnya:

- **SwiftUI `NavigationStack` (iOS 16+):** tambahkan route Tanya AI pada path, lalu
  `navigationDestination` menampilkan `host.makeView()`.
- **UIKit coordinator / `UINavigationController`:**
  `navigation.pushViewController(UIHostingController(rootView: host.makeView(onBack: pop)), animated: true)`.

`TanyaAIBridge` adalah jembatan host ↔ TanyaAI yang hidup selama halaman terbuka; jangan
membuatnya di `body` atau di `makeHost()`. `onSend` mengembalikan `true` bila host menerima
draft (composer dikosongkan) dan `false` untuk mempertahankannya. Nilai ini bukan konfirmasi
request network berhasil. `onNewConversation` opsional; tanpa handler, item menu "Percakapan
baru" disabled. `locale` dan `colors` dibaca saat halaman dibuat.

Rencana stream: host membuka SSE dan meneruskan setiap event **apa adanya** ke bridge
(`receive(_:)`, menyusul bersama contract SSE). TanyaAI yang men-decode event dan
menghentikan loading saat event penghenti datang.

## Halaman sambutan dan menunggu jawaban

Host memanggil inquiry init Tanya AI dan men-decode dengan model miliknya sendiri, lalu
memetakan ke `WelcomeContent`. Model welcome TanyaAI tidak `Decodable`; envelope
`response_code` dan field T&C tetap milik host. Contoh dari sandbox:

```swift
struct TanyaAIInitShortcut: Decodable {
    let title: String
    let description: String
    let iconUrl: String?
    let prompt: String

    var shortcut: WelcomeShortcut {
        WelcomeShortcut(
            title: title, description: description, iconURL: iconUrl.flatMap(URL.init(string:)), prompt: prompt
        )
    }
}
// TanyaAIInitData.welcome = WelcomeContent(greetings: greetings.greeting, shortcuts: shortcuts.map(\.shortcut))
```

| Bagian halaman | Sumber |
| --- | --- |
| Sapaan (`greetings.title`/`description`) | BE |
| Judul, deskripsi, ikon kartu (`shortcuts[].title`/`description`/`iconUrl`) | BE |
| Emblem, latar, judul "Mulai dari sini:", chevron | FE (package) |

Kontrak memakai key `description` (apib awal menulis `descripton`; BE diminta memperbaiki).
`iconURL` nil (kosong/tidak valid) menampilkan ikon fallback tanpa membatalkan kartu lain.

Ketuk kartu mengirim `prompt` lewat `onSend` bridge, sama seperti chat dari composer.
Status menunggu jawaban **milik TanyaAI**: setelah host menerima chat, tombol kirim menjadi
titik bergerak dan kartu nonaktif (draft tetap bisa diketik), dan chat berikutnya ditolak
tanpa diteruskan ke host. Sementara penantian berakhir saat "Percakapan baru"; event
penghenti dari stream menyusul.

```swift
TanyaAIHost(locale: locale, colors: colors, welcome: welcome, bridge: bridge)
```

Ikon kartu dimuat `RemoteImage` DesignKit, pembungkus `KFImage` Kingfisher (dependency SPM
DesignKit, dikunci tepat 8.14.0, butuh Xcode 26). Cache memori + disk memakai `ImageCache.default`
Kingfisher (bawaan: disk kedaluwarsa 7 hari); host bisa mengatur batasnya di bootstrap bila
perlu. Status HTTP di luar 200..<400 dianggap gagal. Gambar di-downsample ke ukuran tampil ×
skala layar, dan unduhan dibatalkan saat view hilang.

Selama mengunduh kotak ikon menampilkan spinner (`ProgressView`); bila `iconUrl` kosong/tidak
valid atau unduhan gagal, tampil ikon default FE (lampu, TODO ganti ikon desain). Kartu tetap
tampil dan bisa diketuk. Kegagalan tidak di-cache, jadi halaman berikutnya mencoba lagi.
Cek di sandbox dengan `Scripts/run_sandbox.sh --broken-icons` (fallback) atau `--slow-icons` (loading).

## Bahasa dan appearance

Copy tersedia untuk `en`, `id`, dan `zh-Hans`, termasuk label kembali. Kode bahasa
Localize_Swift dipakai langsung sebagai `Locale`; bahasa lain jatuh ke English.
Daftarkan bahasa host pada konfigurasi localization target. Jika host belum
mendeklarasikan semua bahasa package, `CFBundleAllowMixedLocalizations = YES`
memungkinkan resource dependency ikut dipilih
([dokumentasi Apple](https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleallowmixedlocalizations)).

Palette mengikuti `colors` pada `TanyaAIHost`; sebelum inquiry selesai memakai palette default.
Halaman Tanya AI memakai light appearance Figma (`.environment(\.colorScheme, .light)`
hanya pada subtree itu, tidak mengubah host). Pemetaan proposition ke palette tetap di host
karena aturan bisnis tidak masuk DesignKit.

## Isi folder `Bridging`

- `TanyaAIHost.swift`: konfigurasi (`locale`, `colors`, `welcome`, `bridge`) dan `makeView()`
  yang memasang bahasa dan palette ke halaman baru.
- `TanyaAIBridge.swift`: objek yang dipegang host (`onSend`, `onNewConversation`, nanti event
  SSE); status menunggu jawaban di dalamnya.

Overload `makeView { ContentView() }` menerima konten SwiftUI untuk area scroll; sandbox
memakainya pada mode `--header-demo`. Konten tidak perlu mempunyai ScrollView, header,
atau composer sendiri, dan dilepas setelah halaman di-pop.

Jalankan `Scripts/run_sandbox.sh --language id`. Buka Tanya AI dari beranda atau dari
halaman detail, kembali dengan tombol back atau swipe dari tepi kiri. `--offline`
membuat kiriman memunculkan blocker host di atas Tanya AI; tombol "Coba lagi"
menutupnya dan draft tetap ada. Welcome sandbox dibaca dari
`Resources/Fixtures/TanyaAIInitDummy.json`; setelah chat/shortcut diterima, sandbox
menunggu jawaban sampai "Percakapan baru" dipilih (belum ada stream).
