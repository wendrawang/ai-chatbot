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
    @MainActor
    func makeHost() -> TanyaAIHost {
        TanyaAIHost(locale: Locale(identifier: Localize.currentLanguage()), service: useCase.service)
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

`TanyaAIHost(locale:colors:service:onNewConversation:)`:

- `service` (`TanyaAIService`) milik host: init sesi, history berhalaman, stream SSE
  persistent, dan kirim chat. Bentuk JSON di [CHAT_CONTRACT.md](CHAT_CONTRACT.md).
  Error jaringan boleh juga dilaporkan host ke blocker halamannya (sandbox: `TanyaAIUseCase`).
- `onNewConversation` opsional; tanpa handler, item menu "Percakapan baru" disabled.
- `locale` dan `colors` dibaca saat halaman dibuat.

Sesi dibuka saat halaman tampil dan stream ditutup saat halaman dilepas.

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

## Isi folder `Host`

- `TanyaAIHost.swift`: konfigurasi (`locale`, `colors`, `service`) dan `makeView()` yang
  memasang bahasa dan palette ke halaman baru.
- `TanyaAIService.swift`: protocol jaringan host dan `TanyaAIServerEvent`.

Jalankan `Scripts/run_sandbox.sh --language id`. Buka Tanya AI dari beranda atau dari
halaman detail, kirim pertanyaan (mis. "saldo", "transfer", "promo", "markdown"), lalu
kembali dengan tombol back atau swipe dari tepi kiri. `--long-history` mengisi history
panjang untuk mencoba paging dan header saat digulir. `--offline` membuat init sesi gagal:
blocker host tampil di atas Tanya AI, dan chat menampilkan "Koneksi terputus. Coba lagi".
