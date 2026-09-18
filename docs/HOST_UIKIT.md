# Host UIKit tanpa SwiftUI root

`TanyaAIModule.makeViewController` membuat graph fitur baru. Presentasikan memakai
`present`, bukan `navigationController.pushViewController`.

Contoh lengkap untuk target demo:

```swift
#if DEBUG
import TanyaAI
import TanyaAITestSupport
import UIKit

final class ChatDemoController: UIViewController {
    func openChat() {
        guard presentedViewController == nil else { return }
        let controller = TanyaAIModule.makeViewController(
            configuration: TanyaAIConfiguration(initialPrompt: "showcase"),
            dependencies: TanyaAIDependencies(
                chatSession: MockTanyaAIChatSession.sandbox(),
                authorizationService: MockTanyaAIAuthorizationService(),
                theme: .sandbox
            ),
            onAction: { [weak self] action in
                self?.handle(action)
            }
        )
        present(controller, animated: true)
    }

    private func handle(_ action: TanyaAIAction) {
        guard let destination = URL(string: action.deeplink),
              destination.scheme == "ocbcid",
              destination.host == "mobile" else { return }
        dismiss(animated: true) {
            print("Demo hand-off:", destination)
        }
    }
}
#endif
```

Hubungkan tombol/menu host ke `openChat()`. Untuk routing sungguhan, ganti `print`
dengan router aplikasi setelah validasi parameter/akses. Jangan menjalankan router
sebelum dismissal selesai.

Perbedaan dua API:

| API | Penanggung jawab |
| --- | --- |
| `TanyaAIHost` + `.tanyaAIHost(...)` | Package memfilter scheme/host dan menutup chat sebelum callback deeplink |
| `TanyaAIModule.makeViewController(...)` | Host menangani validasi action dan dismissal sendiri |

Untuk theme generated, buat `ThemeManager` pada main actor lalu gunakan
`manager.theme` atau `manager.resolve(isDefaultForced: true)` di `dependencies`.
Untuk backend asli, ganti mock session dan authorization service dengan adapter host.

Kembali ke [panduan integrasi](HOST_INTEGRATION.md).
