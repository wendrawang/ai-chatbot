import SwiftUI
import TanyaAIDesignSystem
import TanyaAIDomain

struct TanyaAIMessageTableRow: View {
    let message: TanyaAIMessageItemViewModel?
    let theme: TanyaAITheme
    let onApprovalEdit: (TanyaAIApprovalPayload) -> Void
    let onApprovalCancel: (TanyaAIApprovalPayload) -> Void
    let onApproval: (TanyaAIApprovalPayload) -> Void
    let onAction: (TanyaAIAction) -> Void

    var body: some View {
        Group {
            if let message = message {
                TanyaAIMessageRowView(
                    viewModel: message,
                    onApprovalEdit: onApprovalEdit,
                    onApprovalCancel: onApprovalCancel,
                    onApproval: onApproval,
                    onAction: onAction
                )
            } else {
                TanyaAITypingIndicatorView()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .tanyaAITheme(theme)
    }
}
