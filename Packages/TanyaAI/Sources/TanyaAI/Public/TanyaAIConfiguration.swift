public struct TanyaAIConfiguration: Equatable {
    public let messagePath: String
    public let initialPrompt: String?

    public init(
        messagePath: String = "/sandbox/v1/chat/messages",
        initialPrompt: String? = nil
    ) {
        self.messagePath = messagePath
        self.initialPrompt = initialPrompt
    }
}
