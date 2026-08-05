public struct TanyaAISuggestionPayload: Equatable {
    public let identifier: String
    public let title: String
    public let prompt: String

    public init(
        identifier: String,
        title: String,
        prompt: String
    ) {
        self.identifier = identifier
        self.title = title
        self.prompt = prompt
    }
}
