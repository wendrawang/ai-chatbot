import DesignKit
import TanyaAIDomain

public struct TanyaAIConfiguration: Equatable {
    public let copy: CopyCatalog
    public let welcome: WelcomeConfiguration?
    /// Nil sends nothing automatically; the welcome remains visible until a user sends.
    public let initialPrompt: String?

    public init(
        initialPrompt: String? = nil,
        copy: CopyCatalog = CopyCatalog(),
        welcome: WelcomeConfiguration? = nil
    ) {
        self.initialPrompt = initialPrompt
        self.copy = copy
        self.welcome = welcome
    }
}
