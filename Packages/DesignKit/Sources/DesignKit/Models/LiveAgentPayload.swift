import Foundation

/// The offer to hand the conversation to a person.
///
/// It ends in a deeplink like any other hand-off - the difference is that this
/// one is a decision rather than a link, so it asks before it goes. A customer
/// who is escalated without being asked loses the thread they were following.
public struct LiveAgentPayload: Equatable {
    /// The bubble's own identity, so a decision finds its way back to the
    /// right card when the offer is made twice.
    public let identifier: String
    public let title: String
    public let detail: String?
    public let continueTitle: String
    public let cancelTitle: String
    /// Where "continue" goes. The package does not open it; the host does,
    /// after the feature has closed.
    public let action: Action
    /// True once the offer has been declined. Accepting does not settle it:
    /// a customer who comes back may want to connect again, and the hand-off
    /// costs nothing to repeat.
    public var isDeclined: Bool

    public init(
        identifier: String,
        title: String,
        detail: String? = nil,
        continueTitle: String = "Continue",
        cancelTitle: String = "Cancel",
        action: Action,
        isDeclined: Bool = false
    ) {
        self.identifier = identifier
        self.title = title
        self.detail = detail
        self.continueTitle = continueTitle
        self.cancelTitle = cancelTitle
        self.action = action
        self.isDeclined = isDeclined
    }
}
