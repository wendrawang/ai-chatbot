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
    @Published var webLink: URL?
    let useCase: TanyaAIUseCase          // memiliki TanyaAIService host (SSE + inquiry)
    private let customerName: String

    init(useCase: TanyaAIUseCase = TanyaAIUseCase(), customerName: String) {
        self.useCase = useCase
        self.customerName = customerName
        super.init()
    }

    @MainActor
    func makeHost() -> TanyaAIHost {
        TanyaAIHost(
            customerName: customerName, service: useCase.service,
            locale: Locale(identifier: Localize.currentLanguage())
        ) { [weak self] link in self?.open(link) }
    }

    /// `.web` ke webview host (sheet), `.deeplink` ke handler host, `.phone` ke sistem.
    @MainActor
    func open(_ link: TanyaAILink) { /* lihat sandbox */ }
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

`TanyaAIHost(customerName:service:locale:colors:onOpenLink:)`:

- `customerName` untuk sapaan welcome ("Hi, Lara Croft!").
- `service` (`TanyaAIService`) milik host: SSE chat dan inquiry BE per intent.
- `onOpenLink` menerima `TanyaAILink`: `.web` ke webview host, `.deeplink` ke handler
  deeplink host, `.phone` ke sistem. Tidak ada fallback Safari.
- `locale` dan `colors` dibaca saat halaman dibuat.

Menu titik tiga "Percakapan baru" ditangani Tanya AI sendiri: stream berjalan dihentikan,
layar kembali ke welcome, dan `conversationId` baru dipakai untuk pertanyaan berikutnya.

## 3. Service: SSE chat dan inquiry BE

Host mengimplementasikan `TanyaAIService`; TanyaAI tidak membuka jaringan sendiri.
Kontrak event, blok, markup dan link ada di [CHAT_CONTRACT.md](CHAT_CONTRACT.md).
Contoh dengan `URLSession.bytes` bawaan iOS 15 (token/header mengikuti standar host):

```swift
import Foundation
import TanyaAI

final class HostChatService: TanyaAIService {
    private let session = URLSession.shared
    private let chatURL: URL
    private let inquiryURL: URL

    init(chatURL: URL, inquiryURL: URL) {
        self.chatURL = chatURL
        self.inquiryURL = inquiryURL
    }

    func streamChat(_ request: TanyaAIChatRequest) -> AsyncThrowingStream<TanyaAIServerEvent, Error> {
        // Tangkap nilai, bukan self, agar Task aman untuk strict concurrency/Swift 6.
        let session = session
        let chatURL = chatURL
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var urlRequest = URLRequest(url: chatURL)
                    urlRequest.httpMethod = "POST"
                    urlRequest.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    urlRequest.httpBody = try JSONEncoder().encode(
                        ["conversationId": request.conversationId, "text": request.text]
                    )
                    let (bytes, _) = try await session.bytes(for: urlRequest)
                    var name = "message"
                    // Kontrak: satu baris `data:` per event, didahului `event:`.
                    for try await line in bytes.lines {
                        if line.hasPrefix("event:") {
                            name = line.dropFirst("event:".count).trimmingCharacters(in: .whitespaces)
                        } else if line.hasPrefix("data:") {
                            let data = line.dropFirst("data:".count).trimmingCharacters(in: .whitespaces)
                            continuation.yield(TanyaAIServerEvent(name: name, data: Data(data.utf8)))
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            // Stop atau tutup halaman: koneksi SSE ditutup.
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func inquire(_ intent: TanyaAIIntent) async throws -> Data {
        var urlRequest = URLRequest(url: inquiryURL.appendingPathComponent(intent.name))
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(intent.inquiryId, forHTTPHeaderField: "X-Inquiry-Id")
        urlRequest.httpBody = try JSONEncoder().encode(intent.parameters)
        let (data, _) = try await session.data(for: urlRequest)
        return data
    }
}
```

Error jaringan dari stream menampilkan pesan gagal dengan chip "Coba lagi"; error
inquiry menampilkan pesan gagal tanpa retry. Event `error` dari chat service memakai
`isRetryable` untuk menentukan chip tersebut. Karena service milik host, host juga
boleh melaporkan error yang sama ke blocker halamannya (no internet, session expired);
sandbox mencontohkannya lewat `TanyaAIUseCase` dan `--offline`.

## Bahasa dan appearance

Copy tersedia untuk `en`, `id`, dan `zh-Hans`, termasuk label kembali. Kode bahasa
Localize_Swift dipakai langsung sebagai `Locale`; bahasa lain jatuh ke English.
Daftarkan bahasa host pada konfigurasi localization target. Jika host belum
mendeklarasikan semua bahasa package, `CFBundleAllowMixedLocalizations = YES`
memungkinkan resource dependency ikut dipilih
([dokumentasi Apple](https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleallowmixedlocalizations)).

Palette mengikuti `colors` pada `TanyaAIHost`; sebelum inquiry selesai memakai palette default.
Halaman Tanya AI memakai light appearance Figma (`.environment(\\.colorScheme, .light)`
hanya pada subtree itu, tidak mengubah host). Pemetaan proposition ke palette tetap di host
karena aturan bisnis tidak masuk DesignKit.

## Isi folder `Host`

- `TanyaAIHost.swift`: konfigurasi (`customerName`, `service`, `locale`, `colors`,
  `onOpenLink`) dan `makeView()` yang memasang bahasa dan palette ke halaman baru.
- `TanyaAIService.swift`: protocol SSE + inquiry beserta model request, event, intent.
- `TanyaAILink.swift`: link jawaban yang sudah dikelompokkan (web, deeplink, telepon).

Jalankan `Scripts/run_sandbox.sh --language id`. Buka Tanya AI dari beranda atau dari
halaman detail, coba shortcut Cek Portofolio (intent → tabel) atau pertanyaan bebas
(markup, pilihan, media, action, suggestion), lalu kembali dengan tombol back atau
swipe dari tepi kiri. Service dummy [SandboxChatService](../TanyaAISandboxApp/SandboxChatService.swift)
memutar fixture `Resources/Fixtures/ChatScripts.json` (SSE) dan `ReviewPortfolio.json`
(inquiry BE). `--offline` membuat service gagal: blocker host tampil di atas Tanya AI,
dan setelah "Coba lagi" chat menampilkan pesan gagal dengan chip retry.
