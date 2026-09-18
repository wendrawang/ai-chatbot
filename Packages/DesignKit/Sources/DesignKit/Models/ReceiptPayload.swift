public struct ReceiptPayload: Equatable {
    public let title: String
    public let detail: String
    public let summary: [KeyValue]
    public let footnote: String?

    public init(
        title: String,
        detail: String,
        summary: [KeyValue],
        footnote: String? = nil
    ) {
        self.title = title
        self.detail = detail
        self.summary = summary
        self.footnote = footnote
    }
}
