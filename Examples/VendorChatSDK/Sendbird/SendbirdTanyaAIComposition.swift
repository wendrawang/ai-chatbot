import Foundation
import TanyaAI

/// Composition root for a host whose chat runs on Sendbird.
///
/// Build it once per scene and inject it downward. It is the only place that
/// knows Tanya AI is driven by a vendor session rather than by the host's own
/// networking; screens and coordinators keep depending on the presenter alone.
///
/// What it does *not* do is call `SendbirdChat.initialize` or
/// `SendbirdChat.connect`. Those belong to the application - see
/// `SendbirdAppLifecycle` next to this file.
final class SendbirdTanyaAIComposition {
    private let botUserId: String
    private let authorizing: HostTransactionAuthorizing
    private let configuration: TanyaAIConfiguration

    /// The channel the last presentation settled on.
    ///
    /// Keeping it is what makes closing and reopening the chat continue the
    /// same conversation instead of starting an empty one.
    private var lastChannelURL: String?

    init(
        botUserId: String,
        authorizing: HostTransactionAuthorizing,
        configuration: TanyaAIConfiguration = TanyaAIConfiguration()
    ) {
        self.botUserId = botUserId
        self.authorizing = authorizing
        self.configuration = configuration
    }

    /// One presenter per scene.
    ///
    /// It is handed a factory rather than a fixed dependency set: a vendor
    /// session cannot be shared between presentations, so a fresh adapter is
    /// built each time the feature opens.
    func makePresenter() -> HostTanyaAIPresenter {
        HostTanyaAIPresenter(configuration: configuration) { [self] in
            makeDependencies()
        }
    }

    /// Forgets the stored channel, so the next presentation opens a new
    /// conversation. Wire this to whatever your product calls "new chat";
    /// call it on logout too, so one customer's channel is never reused by
    /// the next person to sign in on this device.
    func startNewConversation() {
        lastChannelURL = nil
    }

    private func makeDependencies() -> TanyaAIDependencies {
        let session = SendbirdChatSessionAdapter(
            botUserId: botUserId,
            channelURL: lastChannelURL
        )
        session.onChannelReady = { [weak self] channelURL in
            self?.lastChannelURL = channelURL
        }
        return TanyaAIDependencies(
            chatSession: session,
            authorizationService: HostTanyaAIAuthorizationService(
                authorizing: authorizing
            ),
            theme: .host
        )
    }
}
