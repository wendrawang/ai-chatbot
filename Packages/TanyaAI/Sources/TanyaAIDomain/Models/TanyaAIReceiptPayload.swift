public struct TanyaAIReceiptPayload: Equatable {
    public let title: String
    public let detail: String
    public let summary: [TanyaAIKeyValue]
    public let footnote: String?

    public init(
        title: String,
        detail: String,
        summary: [TanyaAIKeyValue],
        footnote: String? = nil
    ) {
        self.title = title
        self.detail = detail
        self.summary = summary
        self.footnote = footnote
    }
}
