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
                timestamp: !viewModel.messages.isEmpty ? viewModel.sessionTimestamp : nil,
                latestPromptIdentifier: viewModel.latestPromptIdentifier
            ),
            theme: theme,
            scrollControl: scrollControl,
            handlers: TanyaAIMessageRowHandlers(
                onRetryMessage: { [weak viewModel] in viewModel?.retryMessage($0) },
                onResponseOption: { [weak viewModel] in viewModel?.selectResponseOption($0, $1, $2) },
                onResponseAction: { [weak viewModel] in viewModel?.performResponseAction($0, $1) },
                onResponseDocument: { [weak viewModel] in viewModel?.openResponseDocument($0, $1, $2) },
                onResponseAuthorize: { [weak viewModel] message, identifier, title in
                    viewModel?.authorizeResponse(message, confirmationIdentifier: identifier, title: title)
                },
                onInlineLink: { [weak viewModel] in viewModel?.performInlineLink($0.absoluteString) },
                isHostFlowEnabled: viewModel.isHostFlowEnabled,
                isSendEnabled: viewModel.isSendEnabled
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
