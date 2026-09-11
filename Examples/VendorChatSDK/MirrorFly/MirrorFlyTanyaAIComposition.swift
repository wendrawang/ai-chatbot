import Foundation
import MirrorFlySDK
import TanyaAI

/// Composition root for a host whose chat runs on MirrorFly.
///
/// Build it once per signed-in session and inject it downward. It is the only
/// place that knows Tanya AI is driven by a vendor session; screens depend on
/// the `TanyaAIHost` it hands back and nothing else.
///
/// What it does *not* do is call `ChatManager.initializeSDK` or
/// `registerApiService`. Those belong to the application - initialize at app
/// start, register on login. See the README next to this file.
///
/// Simpler than its Sendbird counterpart: MirrorFly addresses a JID directly,
/// so there is no channel to create and nothing to remember between
/// presentations to continue the same conversation.
final class MirrorFlyTanyaAIComposition {
    private let botJID: String
    private let currentUserJID: String
    private let deeplinkScheme: String
    private let deeplinkHost: String?

    /// - Parameters:
    ///   - botJID: from `FlyUtils.getJid(BOT_USER_NAME)`.
    ///   - currentUserJID: `flyData["userJid"]` as returned by
    ///     `registerApiService` when this customer signed in.
    init(
        botJID: String,
        currentUserJID: String,
        deeplinkScheme: String,
        deeplinkHost: String? = nil
    ) {
        self.botJID = botJID
        self.currentUserJID = currentUserJID
        self.deeplinkScheme = deeplinkScheme
        self.deeplinkHost = deeplinkHost
    }

    /// One host per signed-in session.
    ///
    /// `makeSession` is a factory rather than a fixed instance: a vendor
    /// session cannot be shared between presentations, because the feature
    /// takes ownership of its callback and closes it on dismissal.
    func makeHost(
        theme: TanyaAITheme,
        onDeeplink: @escaping (URL) -> Void
    ) -> TanyaAIHost {
        TanyaAIHost(
            theme: theme,
            deeplinkScheme: deeplinkScheme,
            deeplinkHost: deeplinkHost,
            makeSession: { [botJID, currentUserJID] in
                MirrorFlyChatSessionAdapter(
                    botJID: botJID,
                    currentUserJID: currentUserJID
                )
            },
            onDeeplink: onDeeplink
        )
    }
}
