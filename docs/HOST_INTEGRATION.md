# Membuka Tanya AI dari host app

Tanya AI adalah halaman biasa: `TanyaAIHost.makeViewController()` mengembalikan
`UIViewController` yang di-push oleh navigasi milik host. Package tidak membuat
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

## 1. Host SwiftUI saat ini: router + base `Screen`

Host memakai `NavigationView` dengan pola coordinator → screen → view model → use
case, dan setiap halaman dibungkus base `Screen` (blocker no internet, session
expired, loading dan snackbar dimiliki tiap halaman). Tanya AI tidak didaftarkan
sebagai destinasi per coordinator. Base `Screen` memasang satu `NavigationLink`
Tanya AI; `TanyaAIRouter` memilih `Screen` yang sedang tampil, lalu link milik
halaman itu yang melakukan push.

```
Screen (setiap halaman host)
├── NavigationLink Tanya AI      ← aktif hanya pada Screen yang dipilih router
├── konten halaman
└── blocker host                 ← juga menutup Tanya AI, karena Tanya AI dibungkus Screen

TanyaAIRouter.instance.open()    ← dari view, coordinator, atau callback mana pun
```

Contoh lengkap ada di sandbox, satu tipe per file, dengan nama yang sama seperti host:

| File | Peran |
| --- | --- |
| [Screen](../TanyaAISandboxApp/Host/Screen.swift) | Base screen host + link Tanya AI (`isTanyaAIAvailable`) |
| [TanyaAIRouter](../TanyaAISandboxApp/TanyaAI/TanyaAIRouter.swift) | `open()`/`close()`, halaman yang tampil, sinkron saat SwiftUI pop |
| [TanyaAIDestination](../TanyaAISandboxApp/TanyaAI/TanyaAIDestination.swift) | Tujuan link; `@StateObject` view model, `Screen(isTanyaAIAvailable: false)` |
| [TanyaAIScreen](../TanyaAISandboxApp/TanyaAI/TanyaAIScreen.swift) | `ScreenContent` yang menampilkan halaman package |
| [TanyaAIScreenViewModel](../TanyaAISandboxApp/TanyaAI/TanyaAIScreenViewModel.swift) | `makeHost()` dengan nama nasabah, service, bahasa/theme aktif; link web ke webview host; error ke blocker |
| [TanyaAIUseCase](../TanyaAISandboxApp/TanyaAI/TanyaAIUseCase.swift) | Memiliki `TanyaAIService` host (sandbox: fixture `SandboxChatService`) |
| [WebPage](../TanyaAISandboxApp/Host/WebPage.swift) | Webview host untuk link web jawaban (bukan Safari) |
| [TanyaAIPage](../TanyaAISandboxApp/TanyaAI/TanyaAIPage.swift) | `UIViewControllerRepresentable` untuk `makeViewController()` |
| [MainCoordinator](../TanyaAISandboxApp/Main/MainCoordinator.swift) | Hanya menutup Tanya AI saat logout |
| [UINavigationController+PopGesture](../TanyaAISandboxApp/Host/UINavigationController+PopGesture.swift) | Salinan extension host untuk swipe-back dengan nav bar tersembunyi |

Perubahan pada base `Screen` host hanya tiga hal: property router dan `screenID`,
link yang dibungkus `if isTanyaAIAvailable`, serta `onAppear`/`onDisappear` yang
memberi tahu router. Pemanggil `Screen { ... }` yang sudah ada tidak berubah.

| Kebutuhan | Kode |
| --- | --- |
| Buka Tanya AI | `TanyaAIRouter.instance.open()`; diabaikan bila sudah terbuka |
| Kembali | Tombol back header (`close()`) atau swipe dari tepi kiri |
| Halaman yang tidak boleh membuka Tanya AI | `Screen(isTanyaAIAvailable: false) { ... }` |
| Deeplink dari dalam Tanya AI | `close()` dulu, lalu routing host seperti biasa |
| Ganti bahasa / inquiry proposition selesai | Dibaca `makeHost()` saat Tanya AI dibuka berikutnya |
| Logout | `MainCoordinator` memanggil `TanyaAIRouter.instance.close()` |

Yang sengaja dihindari, dan alasannya (dibuktikan di replika):

- **Push UIKit langsung ke navigation controller milik `NavigationView`.** Bila state
  SwiftUI berubah saat Tanya AI terbuka (session expired, deeplink), stack UIKit dan
  state SwiftUI tidak lagi sinkron.
- **Membungkus `NavigationView` main dengan `UINavigationController` representable.**
  Safe area dan layout main menjadi rusak.

Batasan: link hanya ada pada halaman yang dibungkus `Screen`. Bila `open()` dipanggil
dari sheet, tutup sheet lebih dulu.

## 2. Aplikasi revamp dengan navigasi bersih

Package tidak bergantung pada pola di atas. Router dan base `Screen` milik host; untuk
navigasi lain cukup ganti pemanggilnya:

- **UIKit coordinator / `UINavigationController`:**
  `navigation.pushViewController(host.makeViewController(), animated: true)`. Tanpa
  `onBack`, tombol back halaman melakukan pop sendiri.
- **SwiftUI `NavigationStack` (iOS 16+):** tambahkan route Tanya AI pada path, lalu
  `navigationDestination` menampilkan `TanyaAIPage` seperti di atas.

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
Halaman Tanya AI memakai light appearance Figma (`overrideUserInterfaceStyle` hanya
pada halaman itu, tidak mengubah host). Pemetaan proposition ke palette tetap di host
karena aturan bisnis tidak masuk DesignKit.

## Isi folder `Host`

- `TanyaAIHost.swift`: konfigurasi (`customerName`, `service`, `locale`, `colors`,
  `onOpenLink`) dan `makeViewController()` yang memasang bahasa dan palette ke halaman baru.
- `TanyaAIService.swift`: protocol SSE + inquiry beserta model request, event, intent.
- `TanyaAILink.swift`: link jawaban yang sudah dikelompokkan (web, deeplink, telepon).

Jalankan `Scripts/run_sandbox.sh --language id`. Buka Tanya AI dari beranda atau dari
halaman detail, coba shortcut Cek Portofolio (intent → tabel) atau pertanyaan bebas
(markup, pilihan, media, action, suggestion), lalu kembali dengan tombol back atau
swipe dari tepi kiri. Service dummy [SandboxChatService](../TanyaAISandboxApp/SandboxChatService.swift)
memutar fixture `Resources/Fixtures/ChatScripts.json` (SSE) dan `ReviewPortfolio.json`
(inquiry BE). `--offline` membuat service gagal: blocker host tampil di atas Tanya AI,
dan setelah "Coba lagi" chat menampilkan pesan gagal dengan chip retry.
