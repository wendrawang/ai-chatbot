/// Presentation-only data for reusable option lists. A feature owns the action
/// associated with the identifier; the design system never owns its payload.
public struct SelectionOption: Equatable {
    public let identifier: String
    public let title: String

    public init(identifier: String, title: String) {
        self.identifier = identifier
        self.title = title
    }
}
