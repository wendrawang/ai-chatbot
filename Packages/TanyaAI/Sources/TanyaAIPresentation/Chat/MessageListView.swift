import DesignKit
import SwiftUI

struct MessageListView: View {
    @Environment(\.copyCatalog)
    private var copy
    @Environment(\.theme)
    private var theme
    @ObservedObject
    var viewModel: TanyaAIChatViewModel
    @StateObject
    private var scrollControl = TanyaAIMessageScrollControl()

    var body: some View {
        MessageTableView(
            state: TanyaAIMessageListState(
                messages: viewModel.messages,
                isRestoring: viewModel.isRestoring,
                isTypingRowVisible: viewModel.isTypingRowVisible,
                suggestions: viewModel.isSuggestionRowVisible
                    ? viewModel.suggestions
                    : [],
                suggestionsTitle: viewModel.suggestionsTitle,
                timestamp: viewModel.welcome != nil && !viewModel.messages.isEmpty ? viewModel.sessionTimestamp : nil,
                latestPromptIdentifier: viewModel.latestPromptIdentifier
            ),
            theme: theme,
            scrollControl: scrollControl,
            handlers: TanyaAIMessageRowHandlers(
                approval: .init(
                    onEdit: { [weak viewModel] in viewModel?.editApproval($0) },
                    onCancel: { [weak viewModel] in viewModel?.cancelApproval($0) },
                    onApprove: { [weak viewModel] in viewModel?.approve($0) }
                ),
                choices: .init(
                    onToggle: { [weak viewModel] in viewModel?.toggleChoice($0, $1) },
                    onSubmit: { [weak viewModel] in viewModel?.submitChoices($0) }
                ),
                onRetryMessage: { [weak viewModel] in viewModel?.retryMessage($0) },
                onAction: { [weak viewModel] in viewModel?.perform($0) },
                onSuggestion: { [weak viewModel] in viewModel?.sendSuggestion($0) },
                onConfirmation: { [weak viewModel] in viewModel?.confirm($0) },
                onAnswerOption: { [weak viewModel] in viewModel?.selectAnswerOption($0, $1) },
                onResponseOption: { [weak viewModel] in viewModel?.selectResponseOption($0, $1, $2) },
                onResponseAction: { [weak viewModel] in viewModel?.performResponseAction($0, $1) },
                onResponseDocument: { [weak viewModel] in viewModel?.openResponseDocument($0, $1, $2) },
                onResponseAuthorize: { [weak viewModel] message, identifier, title in
                    viewModel?.authorizeResponse(message, confirmationIdentifier: identifier, title: title)
                },
                onInlineLink: { [weak viewModel] in viewModel?.performInlineLink($0.absoluteString) },
                isHostFlowEnabled: viewModel.isHostFlowEnabled,
                isSendEnabled: viewModel.isSendEnabled,
                onDeclineLiveAgent: { [weak viewModel] in viewModel?.declineLiveAgent($0) }
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
