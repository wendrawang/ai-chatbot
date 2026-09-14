import DesignKit
import TanyaAIDomain

/// The callbacks a message row can raise, carried as one value.
///
/// They always travel together - the list hands them to the table view, which
/// hands them to the row - so grouping them keeps each signature short instead
/// of repeating the same closures at every level.
///
/// Grouped by the bubble that raises them rather than listed flat: a card with
/// three buttons contributes three closures, and one list of nine reads as
/// nine unrelated things.
struct TanyaAIMessageRowHandlers {
    struct Approval {
        let onEdit: (ApprovalPayload) -> Void
        let onCancel: (ApprovalPayload) -> Void
        let onApprove: (ApprovalPayload) -> Void

        static let inert = Approval(
            onEdit: { _ in },
            onCancel: { _ in },
            onApprove: { _ in }
        )
    }

    struct Choices {
        /// Identified by the bubble, then the chip inside it: the same
        /// question may be asked twice in one conversation.
        let onToggle: (ChoicesPayload, String) -> Void
        let onSubmit: (ChoicesPayload) -> Void

        static let inert = Choices(
            onToggle: { _, _ in },
            onSubmit: { _ in }
        )
    }

    let approval: Approval
    let choices: Choices
    let onAction: (Action) -> Void
    let onSuggestion: (Suggestion) -> Void

    /// Placeholder for the coordinator's stored property, before the first
    /// `update` delivers the real handlers.
    static let inert = TanyaAIMessageRowHandlers(
        approval: .inert,
        choices: .inert,
        onAction: { _ in },
        onSuggestion: { _ in }
    )
}
