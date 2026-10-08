import DesignKit
import TanyaAIDomain

public struct TanyaAIConfiguration: Equatable {
    /// Language and localized host overrides for this presentation.
    public let copy: CopyCatalog
    /// Optional summaries supplied by the host, empty by default.
    public let historyItems: [ConversationSummary]

    /// Optional first message sent when opening; nil sends nothing automatically.
    public let initialPrompt: String?

    /// Ways in, shown above the keyboard and unchanged by use.
    ///
    /// The host supplies them - fetched from its own backend before the chat
    /// opens - which is why there is no protocol for them. They are a value,
    /// not a service.
    ///
    /// Distinct from the prompts a reply offers: those answer the question
    /// just asked and disappear once answered.
    public let shortcuts: [Suggestion]

    public init(
        initialPrompt: String? = nil,
        shortcuts: [Suggestion] = [],
        copy: CopyCatalog = CopyCatalog(),
        historyItems: [ConversationSummary] = []
    ) {
        self.copy = copy
        self.historyItems = historyItems
        self.initialPrompt = initialPrompt
        self.shortcuts = shortcuts
    }
}
