import DesignKit
import SwiftUI

struct TanyaAIMessageListView: View {
    @ObservedObject var viewModel: TanyaAIChatViewModel
    @Environment(\.theme) private var theme

    var body: some View {
        TanyaAIMessageTableView(
            state: TanyaAIMessageListState(
                messages: viewModel.messages,
                isRestoring: viewModel.isRestoring,
                isTypingRowVisible: viewModel.isTypingRowVisible,
                suggestions: viewModel.isSuggestionRowVisible
                    ? viewModel.suggestions
                    : [],
                suggestionsTitle: viewModel.suggestionsTitle
            ),
            theme: theme,
            handlers: TanyaAIMessageRowHandlers(
                approval: .init(
                    onEdit: viewModel.editApproval,
                    onCancel: viewModel.cancelApproval,
                    onApprove: viewModel.approve
                ),
                choices: .init(
                    onToggle: viewModel.toggleChoice,
                    onSubmit: viewModel.submitChoices
                ),
                onAction: viewModel.perform,
                onSuggestion: viewModel.sendSuggestion,
                onDeclineLiveAgent: viewModel.declineLiveAgent
            )
        )
    }
}
