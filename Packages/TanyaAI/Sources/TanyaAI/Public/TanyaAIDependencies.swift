import TanyaAIContracts
import TanyaAIDesignSystem

/// What the host injects into one feature graph.
///
/// The chat reaches the backend through a vendor chat SDK, adapted by the host
/// to `TanyaAIChatSession`. The package never imports the vendor.
public struct TanyaAIDependencies {
    public let chatSession: TanyaAIChatSession
    public let authorizationService: TanyaAIAuthorizationService
    public let theme: TanyaAITheme

    public init(
        chatSession: TanyaAIChatSession,
        authorizationService: TanyaAIAuthorizationService,
        theme: TanyaAITheme
    ) {
        self.chatSession = chatSession
        self.authorizationService = authorizationService
        self.theme = theme
    }
}
