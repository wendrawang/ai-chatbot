import Foundation
import TanyaAI

/// Composition root for a host whose chat runs on Sendbird.
///
/// Build it once per signed-in session and inject it downward. It is the only
/// place that knows Tanya AI is driven by a vendor session; screens depend on
/// the `TanyaAIHost` it hands back and nothing else.
///
/// What it does *not* do is call `SendbirdChat.initialize` or
/// `SendbirdChat.connect`. Those belong to the application - see
/// `SendbirdAppLifecycle` next to this file.
final class SendbirdTanyaAIComposition {
    private let botUserId: String
    private let deeplinkScheme: String
    private let deeplinkHost: String?

    /// The channel the last presentation settled on.
    ///
    /// Keeping it is what makes closing and reopening the chat continue the
    /// same conversation instead of starting an empty one.
    private var lastChannelURL: String?

    init(
        botUserId: String,
        deeplinkScheme: String,
        deeplinkHost: String? = nil
    ) {
        self.botUserId = botUserId
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
            makeSession: { [weak self] in
                self?.makeSession() ?? SendbirdChatSessionAdapter(
                    botUserId: ""
                )
            },
            onDeeplink: onDeeplink
        )
    }

    /// Forgets the stored channel, so the next presentation opens a new
    /// conversation. Wire this to whatever your product calls "new chat";
    /// call it on logout too, so one customer's channel is never reused by
    /// the next person to sign in on this device.
    func startNewConversation() {
        lastChannelURL = nil
    }

    private func makeSession() -> SendbirdChatSessionAdapter {
        let session = SendbirdChatSessionAdapter(
            botUserId: botUserId,
            channelURL: lastChannelURL
        )
        session.onChannelReady = { [weak self] channelURL in
            self?.lastChannelURL = channelURL
        }
        return session
    }
}
