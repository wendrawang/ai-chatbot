import TanyaAIContracts
import TanyaAIDesignSystem

/// What the host injects into one feature graph.
///
/// The chat reaches the backend through exactly one of two transports:
///
/// - `streamingTransport`: the host's own networking, request-shaped (SSE);
/// - `chatSession`: a vendor chat SDK, session-shaped.
///
/// Everything above the repository is identical either way, so the typed
/// bubbles, the PIN sheet, and the deeplink hand-off do not change.
public struct TanyaAIDependencies {
    public let streamingTransport: TanyaAIStreamingTransport?
    public let chatSession: TanyaAIChatSession?
    public let authorizationService: TanyaAIAuthorizationService
    public let theme: TanyaAITheme

    /// Host-owned SSE networking.
    public init(
        streamingTransport: TanyaAIStreamingTransport,
        authorizationService: TanyaAIAuthorizationService,
        theme: TanyaAITheme
    ) {
        self.streamingTransport = streamingTransport
        self.chatSession = nil
        self.authorizationService = authorizationService
        self.theme = theme
    }

    /// A vendor chat SDK, adapted by the host to `TanyaAIChatSession`.
    ///
    /// The package never imports the vendor: the adapter lives in the host and
    /// translates the SDK's callbacks into `TanyaAIChatSessionEvent`.
    public init(
        chatSession: TanyaAIChatSession,
        authorizationService: TanyaAIAuthorizationService,
        theme: TanyaAITheme
    ) {
        self.streamingTransport = nil
        self.chatSession = chatSession
        self.authorizationService = authorizationService
        self.theme = theme
    }
}
