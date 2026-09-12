import DesignKit
import SwiftUI

struct TanyaAIMessageListView: View {
    @ObservedObject var viewModel: TanyaAIChatViewModel
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        TanyaAIMessageTableView(
            state: TanyaAIMessageListState(
                messages: viewModel.messages,
                isRestoring: viewModel.isRestoring,
                showsTypingRow: viewModel.showsTypingRow,
                suggestions: viewModel.showsSuggestions
                    ? viewModel.suggestions
                    : []
            ),
            theme: theme,
            handlers: TanyaAIMessageRowHandlers(
                onApprovalEdit: viewModel.editApproval,
                onApprovalCancel: viewModel.cancelApproval,
                onApproval: viewModel.approve,
                onAction: viewModel.perform,
                onSuggestion: viewModel.sendSuggestion
            )
        )
    }
}
