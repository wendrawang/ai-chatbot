import DesignKit
import TanyaAIDomain

/// The callbacks a message row can raise, carried as one value.
///
/// They always travel together - the list hands them to the table view, which
/// hands them to the row - so grouping them keeps each signature short instead
/// of repeating the same closures at every level.
struct TanyaAIMessageRowHandlers {
    let onApprovalEdit: (ApprovalPayload) -> Void
    let onApprovalCancel: (ApprovalPayload) -> Void
    let onApproval: (ApprovalPayload) -> Void
    let onAction: (Action) -> Void
    let onSuggestion: (Suggestion) -> Void

    /// Placeholder for the coordinator's stored property, before the first
    /// `update` delivers the real handlers.
    static let inert = TanyaAIMessageRowHandlers(
        onApprovalEdit: { _ in },
        onApprovalCancel: { _ in },
        onApproval: { _ in },
        onAction: { _ in },
        onSuggestion: { _ in }
    )
}
