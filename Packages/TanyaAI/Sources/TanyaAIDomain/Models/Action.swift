/// A deeplink the response asks the host to open.
///
/// The feature never opens it. It hands the string to the host, and the host
/// decides whether the deeplink is allowed and what to do with it. That
/// decision cannot live in the package: only the host knows which schemes and
/// destinations belong to the app.
public struct Action: Equatable {
    public enum DestinationType: String, Equatable, Decodable {
        case deeplink, webview
    }

    public let destinationType: DestinationType

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

    public init(identifier: String, deeplink: String, destinationType: DestinationType = .deeplink) {
        self.destinationType = destinationType
        self.identifier = identifier
        self.deeplink = deeplink
    }
}
