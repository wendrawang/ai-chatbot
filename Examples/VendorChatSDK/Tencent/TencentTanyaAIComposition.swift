import Foundation
import TanyaAI

/// Build once per signed-in host session; keep the returned host alive.
final class TencentTanyaAIComposition {
    private let botUserID: String
    private let deeplinkScheme: String
    private let deeplinkHost: String?

    init(botUserID: String, deeplinkScheme: String, deeplinkHost: String? = nil) {
        self.botUserID = botUserID
        self.deeplinkScheme = deeplinkScheme
        self.deeplinkHost = deeplinkHost
    }

    func makeHost(
        theme: TanyaAITheme,
        onDeeplink: @escaping (URL) -> Void
    ) -> TanyaAIHost {
        TanyaAIHost(
            theme: theme,
            deeplinkScheme: deeplinkScheme,
            deeplinkHost: deeplinkHost,
            makeSession: { [botUserID] in
                TencentChatSessionAdapter(botUserID: botUserID)
            },
            onDeeplink: onDeeplink
        )
    }
}
