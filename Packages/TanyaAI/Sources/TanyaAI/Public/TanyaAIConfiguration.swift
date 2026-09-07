public struct TanyaAIConfiguration: Equatable {
    /// Sent as the customer's first message when the chat opens. Nil opens an
    /// empty conversation.
    public let initialPrompt: String?

    public init(initialPrompt: String? = nil) {
        self.initialPrompt = initialPrompt
    }
}
