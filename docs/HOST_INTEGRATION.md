# Membuka Tanya AI dari host app

Tanya AI adalah halaman biasa yang di-push ke **jalur navigasi bersih milik host**
(`RevampNavigationController`). Package tidak membuat modal, animasi, atau navigation
stack sendiri: push, pop, animasi dan swipe-back semuanya bawaan UIKit.

```
Window (SceneDelegate)
└── RevampNavigationController      ← jalur bersih milik host, nav bar disembunyikan
    ├── Main legacy                 ← NavigationView/tab lama tetap di dalam sini
    ├── Tanya AI                    ← tanyaAI.makeViewController()
    └── halaman revamp berikutnya   ← (nanti) halaman lanjutan Tanya AI, dsb.
```

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

## 1. Jalur navigasi revamp di host

Satu class kecil di host. Nav bar disembunyikan karena setiap halaman revamp
menggambar header 1:1 Figma sendiri; delegate gesture mengaktifkan lagi swipe-back
bawaan yang ikut mati saat nav bar disembunyikan.

```swift
import UIKit

final class RevampNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarHidden(true, animated: false)
        interactivePopGestureRecognizer?.delegate = self
    }

    /// Swipe-back hanya saat ada halaman untuk kembali dan tidak sedang transisi.
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        topViewController !== viewControllers.first && transitionCoordinator == nil
    }
}
```

Pasang sebagai root window saat masuk main (setelah login):

```swift
// SceneDelegate / router login milik host
let main = MainTabBarController()                     // main legacy, tidak diubah
let revampNavigation = RevampNavigationController(rootViewController: main)
window.rootViewController = revampNavigation
```

Saat logout atau session timeout, host mengganti root window ke prelogin seperti
biasa. Seluruh jalur, termasuk Tanya AI yang sedang terbuka, ikut dilepas.

## 2. Session main dan cara membuka

```swift
import Combine
import DesignKit
import Localize_Swift
import TanyaAI
import UIKit

/// Hidup selama user berada di main; dibuat saat login, dilepas saat kembali ke prelogin.
@MainActor
final class MainSession {
    let tanyaAI: TanyaAIHost
    weak var revampNavigation: UINavigationController?
    private weak var tanyaAIPage: UIViewController?
    private var cancellables = Set<AnyCancellable>()

    init() {
        tanyaAI = TanyaAIHost(locale: Locale(identifier: Localize.currentLanguage())) { _ in true }
        // Localize.setCurrentLanguage(_:) dari Setting > Language mengirim notifikasi ini.
        NotificationCenter.default
            .publisher(for: Notification.Name(LCLLanguageChangeNotification))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.applyCurrentLanguage() }
            .store(in: &cancellables)
    }

    /// Entry point mana pun di main: tombol, tab, notifikasi, deeplink.
    func openTanyaAI() {
        guard tanyaAIPage == nil, let revampNavigation else { return }
        let page = tanyaAI.makeViewController()
        tanyaAIPage = page
        revampNavigation.pushViewController(page, animated: true)
    }

    /// Panggil dari tempat inquiry proposition berhasil.
    func didLoadProposition(_ proposition: CustomerProposition) {
        switch proposition {
        case .premier: tanyaAI.colors = PremierColorConstants()
        case .privateBanking: tanyaAI.colors = PrivateColorConstants()
        default: tanyaAI.colors = DefaultColorConstants()
        }
    }

    private func applyCurrentLanguage() {
        tanyaAI.locale = Locale(identifier: Localize.currentLanguage())
    }
}
```

| Kebutuhan | Kode |
| --- | --- |
| Buka Tanya AI | `session.openTanyaAI()`; pengecekan `tanyaAIPage` mencegah push ganda |
| Kembali | Tombol back header melakukan pop; swipe dari tepi kiri juga pop (bawaan UIKit) |
| Back dengan aturan host | `tanyaAI.makeViewController(onBack: { ... })`; tanpa `onBack`, halaman pop sendiri |
| Deeplink dari dalam Tanya AI | `revampNavigation.popViewController(animated:)` lalu push/route tujuan, atau langsung `setViewControllers` |
| Ganti bahasa | Otomatis lewat notifikasi Localize_Swift; halaman yang terbuka langsung ikut |
| Inquiry proposition selesai | `session.didLoadProposition(result)`; halaman yang terbuka langsung ikut |
| Logout / session timeout | Ganti root window ke prelogin; Tanya AI ikut dilepas |

`onSend` mengembalikan `true` bila host menerima draft (composer dikosongkan) dan
`false` untuk mempertahankannya. Nilai ini bukan konfirmasi request network berhasil.
`onNewConversation` opsional; tanpa handler, item menu "Percakapan baru" disabled.

## Blocker host: no internet, session expired, dan sejenisnya

Karena Tanya AI hanya halaman di stack, blocker host tetap muncul di atasnya tanpa
perubahan apa pun di Tanya AI:

- **UIKit** (`present` dari `revampNavigation`, dari top view controller, atau window
  overlay): tampil di atas Tanya AI.
- **Sheet SwiftUI yang ditempel pada view main** (mis. bottom sheet session expired):
  tetap tampil walaupun main sedang tertutup Tanya AI.

Keduanya dibuktikan di `RevampNavigationTests`. Setelah session expired, host
melanjutkan alurnya (mis. ganti root ke prelogin) seperti biasa.

## Bahasa dan appearance

Copy tersedia untuk `en`, `id`, dan `zh-Hans`, termasuk label kembali. Kode bahasa
Localize_Swift dipakai langsung sebagai `Locale`; bahasa lain jatuh ke English.
Daftarkan bahasa host pada konfigurasi localization target. Jika host belum
mendeklarasikan semua bahasa package, `CFBundleAllowMixedLocalizations = YES`
memungkinkan resource dependency ikut dipilih
([dokumentasi Apple](https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleallowmixedlocalizations)).

Palette mengikuti `tanyaAI.colors`; sebelum inquiry selesai memakai palette default.
Halaman Tanya AI memakai light appearance Figma (`overrideUserInterfaceStyle` hanya
pada halaman itu, tidak mengubah host). Pemetaan proposition ke palette tetap di host
karena aturan bisnis tidak masuk DesignKit.

## Isi folder `Host`

- `TanyaAIHost.swift`: konfigurasi (`locale`, `colors`, `onSend`) dan
  `makeViewController()` untuk di-push host.
- `TanyaAIHostEnvironment.swift`: meneruskan `locale`/`colors` ke halaman yang terbuka.

Overload `makeViewController { ContentView() }` menerima konten SwiftUI untuk area
scroll; sandbox memakainya pada mode `--header-demo`. Konten tidak perlu mempunyai
ScrollView, header, atau composer sendiri, dan dilepas setelah halaman di-pop.

Contoh lengkap host ada di sandbox: [AppDelegate](../TanyaAISandboxApp/AppDelegate.swift),
[SceneDelegate](../TanyaAISandboxApp/SceneDelegate.swift),
[RevampNavigationController](../TanyaAISandboxApp/RevampNavigationController.swift), dan
[SandboxRouter](../TanyaAISandboxApp/SandboxRouter.swift). Jalankan
`Scripts/run_sandbox.sh --language id`, tekan "Buka Tanya AI", lalu kembali dengan
tombol back atau swipe dari tepi kiri.
