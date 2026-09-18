import DesignKit

public struct TanyaAIConfiguration: Equatable {
    /// Sent as the customer's first message when the chat opens. Nil opens an
    /// empty conversation.
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
        shortcuts: [Suggestion] = []
    ) {
        self.initialPrompt = initialPrompt
        self.shortcuts = shortcuts
    }
}
