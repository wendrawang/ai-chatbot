import DesignKit
import SwiftUI
import TanyaAIDomain

struct MessageRowView: View {
    @Environment(\.copyCatalog)
    private var copy

    @ObservedObject
    var viewModel: TanyaAIMessageItemViewModel
    let handlers: TanyaAIMessageRowHandlers

    var body: some View {
        HStack(spacing: FigmaSize.spacing8.sizeInArtwork) {
            if viewModel.role == .user {
                Spacer(minLength: FigmaSize.spacing48.sizeInArtwork)
            }

            VStack(
                alignment: viewModel.role == .user ? .trailing : .leading,
                spacing: FigmaSize.spacing4.sizeInArtwork
            ) {
                content
                deliveryStatus
            }

        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(
            viewModel.role == .user ? "chat.user.\(viewModel.identifier)" : "chat.assistant.\(viewModel.identifier)"
        )
    }

    @ViewBuilder
    private var deliveryStatus: some View {
        if viewModel.delivery == .pending {
            Text(copy.chat("chat.sending"))
                .designFont(.caption)
        } else if viewModel.delivery == .failed {
            Button(copy.chat("chat.retrySend")) { handlers.onRetryMessage(viewModel.identifier) }
                .designFont(.caption)
                .frame(minHeight: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork)
                .accessibilityIdentifier("chat.retrySend.\(viewModel.identifier)")
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.content {
        case .text(let text):
            TextBubble(
                text: text,
                isUser: viewModel.role == .user,
                onLink: handlers.onInlineLink
            )
        case .response(let payload):
            ResponseBlocksView(payload: payload, messageIdentifier: viewModel.identifier, handlers: handlers)
        case .unsupported(let message):
            unsupported(message)
        }
    }

    private func unsupported(_ message: String?) -> some View {
        TextBubble(text: message ?? copy.chat("chat.unsupported"), isUser: false, fontRole: .footnote)
    }
}
