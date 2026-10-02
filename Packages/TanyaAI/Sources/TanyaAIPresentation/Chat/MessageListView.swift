import DesignKit
import SwiftUI

struct MessageListView: View {
    @ObservedObject var viewModel: TanyaAIChatViewModel
    @Environment(\.theme) private var theme

    var body: some View {
        MessageTableView(
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
                onAnswerOption: viewModel.selectAnswerOption,
                onDeclineLiveAgent: viewModel.declineLiveAgent
            )
        )
    }
}
