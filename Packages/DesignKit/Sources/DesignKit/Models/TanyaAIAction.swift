/// A deeplink the response asks the host to open.
///
/// The feature never opens it. It hands the string to the host, and the host
/// decides whether the deeplink is allowed and what to do with it. That
/// decision cannot live in the package: only the host knows which schemes and
/// destinations belong to the app.
public struct TanyaAIAction: Equatable {
    /// Stable identifier for the action, used for accessibility identifiers
    /// and analytics. Not a destination.
    public let identifier: String

    /// The deeplink exactly as the backend sent it, for example
    /// `ocbcid://mobile?type=transfer`.
    ///
    /// Kept as a `String` rather than a `URL` on purpose: an unparseable value
    /// must reach the host's validation and be rejected there, not disappear
    /// silently while decoding.
    public let deeplink: String

    public init(identifier: String, deeplink: String) {
        self.identifier = identifier
        self.deeplink = deeplink
    }
}

/// One button on an action card.
public struct TanyaAIActionButton: Equatable, Identifiable {
    /// Visual weight only. It carries no behaviour and no permission.
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

/// A set of hand-off links.
///
/// No heading of its own. Whatever explains the hand-off arrives as an
/// ordinary reply before it, so a title here would say the same thing twice -
/// and a field the UI never draws is a promise the contract does not keep.
public struct TanyaAIActionPayload: Equatable {
    public let buttons: [TanyaAIActionButton]

    public init(buttons: [TanyaAIActionButton]) {
        self.buttons = buttons
    }
}
