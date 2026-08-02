public struct TanyaAISuggestion: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let prompt: String

    public init(
        identifier: String,
        title: String,
        prompt: String
    ) {
        id = identifier
        self.title = title
        self.prompt = prompt
    }
}
