/// A host-defined destination requested from inside the feature.
///
/// The backend never sends a URL. It sends a route key and parameters, and the
/// host decides what that route means, whether it is allowed, and how to reach
/// it. The feature itself never opens anything.
public struct TanyaAIAction: Equatable {
    public let identifier: String
    public let route: String
    public let parameters: [String: String]

    public init(
        identifier: String,
        route: String,
        parameters: [String: String] = [:]
    ) {
        self.identifier = identifier
        self.route = route
        self.parameters = parameters
    }
}

public struct TanyaAIActionButton: Equatable, Identifiable {
    public enum Style: String, Equatable {
        case primary
        case secondary
    }

    public let title: String
    public let style: Style
    public let action: TanyaAIAction

    public var id: String { action.identifier }

    public init(
        title: String,
        style: Style = .primary,
        action: TanyaAIAction
    ) {
        self.title = title
        self.style = style
        self.action = action
    }
}

public struct TanyaAIActionPayload: Equatable {
    public let title: String?
    public let detail: String?
    public let buttons: [TanyaAIActionButton]

    public init(
        title: String?,
        detail: String?,
        buttons: [TanyaAIActionButton]
    ) {
        self.title = title
        self.detail = detail
        self.buttons = buttons
    }
}
