/// Display data supplied by the host; no fixture history is added by the package.
public struct ConversationSummary: Equatable {
    public let identifier: String
    public let title: String
    public let detail: String

    public init(identifier: String, title: String, detail: String) {
        self.identifier = identifier
        self.title = title
        self.detail = detail
    }
}
