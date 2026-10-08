import Foundation
import TanyaAI

/// Build once per signed-in host session; keep the returned host alive.
final class TencentTanyaAIComposition {
    private let groupID: String
    private let deeplinkScheme: String
    private let deeplinkHost: String?

    init(groupID: String, deeplinkScheme: String, deeplinkHost: String? = nil) {
        self.groupID = groupID
        self.deeplinkScheme = deeplinkScheme
        self.deeplinkHost = deeplinkHost
    }

    func makeHost(
        theme: TanyaAITheme,
        onDestination: ((TanyaAIAction, URL) -> Void)? = nil,
        onConfirmation: ((TanyaAIConfirmationPayload) -> Void)? = nil,
        onDeeplink: @escaping (URL) -> Void
    ) -> TanyaAIHost {
        TanyaAIHost(
            theme: theme,
            deeplinkScheme: deeplinkScheme,
            deeplinkHost: deeplinkHost,
            makeSession: { [groupID] in
                TencentChatSessionAdapter(groupID: groupID)
            },
            onDestination: onDestination,
            onConfirmation: onConfirmation,
            onDeeplink: onDeeplink
        )
    }
}
