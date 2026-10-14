import DesignKit
import TanyaAIContracts

/// One session and a theme snapshot for one feature presentation.
public struct TanyaAIDependencies {
    public let chatSession: TanyaAIChatSession
    public let theme: Theme

    public init(chatSession: TanyaAIChatSession, theme: Theme) {
        self.chatSession = chatSession
        self.theme = theme
    }
}
