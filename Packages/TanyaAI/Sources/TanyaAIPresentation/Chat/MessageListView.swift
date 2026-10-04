import DesignKit
import SwiftUI

struct MessageListView: View {
    @ObservedObject var viewModel: TanyaAIChatViewModel
    @StateObject private var scrollControl = TanyaAIMessageScrollControl()
    @Environment(\.copyCatalog) private var copy

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
            scrollControl: scrollControl,
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
                onConfirmation: viewModel.confirm,
                onAnswerOption: viewModel.selectAnswerOption,
                onDeclineLiveAgent: viewModel.declineLiveAgent
            )
        )
        .overlay(alignment: .bottom) {
            if scrollControl.isAwayFromLatest && !viewModel.isRestoring {
                ScrollToLatestButton(label: copy.chat("chat.latest"), onTap: scrollControl.returnToLatest)
                    .accessibilityIdentifier("chat.latest")
                    .padding(.bottom, DesignKitMetrics.Spacing.regular.sizeInArtwork)
            }
        }
    }
}
