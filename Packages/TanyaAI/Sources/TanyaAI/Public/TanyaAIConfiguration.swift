public struct TanyaAIConfiguration: Equatable {
    public let messagePath: String
    public let initialPrompt: String?

    /// Where the customer opened the chat from.
    ///
    /// Set it per presentation: the same screen opened with different values
    /// is a different context, and each presentation builds a fresh graph
    /// anyway.
    public let context: TanyaAIContext?

    public init(
        messagePath: String = "/sandbox/v1/chat/messages",
        initialPrompt: String? = nil,
        context: TanyaAIContext? = nil
    ) {
        self.messagePath = messagePath
        self.initialPrompt = initialPrompt
        self.context = context
    }
}
