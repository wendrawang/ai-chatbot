/// A display item. The feature resolves its identifier to an action or prompt.
public struct QuickActionData: Codable, Equatable {
    public let identifier: String
    public let title: String
    public let subtitle: String
    public let symbolName: String

    public init(identifier: String, title: String, subtitle: String, symbolName: String) {
        self.identifier = identifier
        self.title = title
        self.subtitle = subtitle
        self.symbolName = symbolName
    }
}
