import TanyaAIDomain

/// The callbacks a message row can raise, carried as one value.
///
/// They always travel together - the list hands them to the table view, which
/// hands them to the row - so grouping them keeps each signature short instead
/// of repeating the same four closures at every level.
struct TanyaAIMessageRowHandlers {
    let onApprovalEdit: (TanyaAIApprovalPayload) -> Void
    let onApprovalCancel: (TanyaAIApprovalPayload) -> Void
    let onApproval: (TanyaAIApprovalPayload) -> Void
    let onAction: (TanyaAIAction) -> Void

    /// Placeholder for the coordinator's stored property, before the first
    /// `update` delivers the real handlers.
    static let inert = TanyaAIMessageRowHandlers(
        onApprovalEdit: { _ in },
        onApprovalCancel: { _ in },
        onApproval: { _ in },
        onAction: { _ in }
    )
}
