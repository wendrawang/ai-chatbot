import TanyaAIContracts
import TanyaAIDesignSystem

/// What the host injects into one feature graph.
///
/// The chat reaches the backend through a vendor chat SDK, adapted by the host
/// to `TanyaAIChatSession`. The package never imports the vendor.
public struct TanyaAIDependencies {
    public let chatSession: TanyaAIChatSession

    /// Runs the in-feature PIN sheet.
    ///
    /// Only reached by a confirmation the chat authorizes itself - that is,
    /// an approval with no `handoff`. A host whose confirmations all hand off
    /// to its existing flows never needs one, and passes nil.
    public let authorizationService: TanyaAIAuthorizationService?
    public let theme: TanyaAITheme

    public init(
        chatSession: TanyaAIChatSession,
        authorizationService: TanyaAIAuthorizationService? = nil,
        theme: TanyaAITheme
    ) {
        self.chatSession = chatSession
        self.authorizationService = authorizationService
        self.theme = theme
    }
}
