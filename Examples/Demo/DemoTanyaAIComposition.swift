#if DEBUG
import Foundation
import TanyaAI
import TanyaAITestSupport

/// Demo lokal. Semua respons berasal dari fixture, tanpa koneksi backend.
final class DemoTanyaAIComposition {
    private let authorization = MockTanyaAIAuthorizationService(acceptedPIN: "123456")
    private let deeplinkScheme: String
    private let deeplinkHost: String?

    /// Fixture bawaan memakai ocbcid://mobile. Scheme lain akan ditolak filter host.
    init(deeplinkScheme: String = "ocbcid", deeplinkHost: String? = "mobile") {
        self.deeplinkScheme = deeplinkScheme
        self.deeplinkHost = deeplinkHost
    }

    func makeHost(
        theme: TanyaAITheme = .sandbox,
        initialPrompt: String? = nil,
        onDeeplink: @escaping (URL) -> Void
    ) -> TanyaAIHost {
        TanyaAIHost(
            theme: theme,
            authorizationService: authorization,
            deeplinkScheme: deeplinkScheme,
            deeplinkHost: deeplinkHost,
            initialPrompt: initialPrompt,
            makeSession: { MockTanyaAIChatSession.sandbox() },
            onDeeplink: onDeeplink
        )
    }

    /// Mengirim "showcase" otomatis setelah layar chat dibuka.
    func makeShowcaseHost(
        theme: TanyaAITheme = .sandbox,
        onDeeplink: @escaping (URL) -> Void
    ) -> TanyaAIHost {
        makeHost(theme: theme, initialPrompt: "showcase", onDeeplink: onDeeplink)
    }
}
#endif
