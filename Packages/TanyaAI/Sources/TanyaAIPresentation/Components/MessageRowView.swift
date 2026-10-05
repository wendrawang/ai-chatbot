import DesignKit
import SwiftUI
import TanyaAIDomain

struct MessageRowView: View {

    @Environment(\.copyCatalog) private var copy
    @ObservedObject var viewModel: TanyaAIMessageItemViewModel
    let handlers: TanyaAIMessageRowHandlers

    var body: some View {
        HStack(spacing: FigmaSize.spacing8.sizeInArtwork) {
            if viewModel.role == .user {
                Spacer(minLength: FigmaSize.spacing48.sizeInArtwork)
            }

            content

            if viewModel.role != .user {
                Spacer(minLength: FigmaSize.spacing32.sizeInArtwork)
            }
        }
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.content {
        case .text(let text):
            TextBubble(
                text: text,
                isUser: viewModel.role == .user
            )
        case .answer(let payload):
            answer(payload)
        case .image(let payload):
            ImageBubble(payload: payload)
        case .information(let payload):
            InformationBubble(payload: payload)
        case .chart(let payload):
            ChartBubble(payload: payload)
        case .portfolio(let payload):
            PortfolioBubble(payload: payload)
        case .financialList(let payload):
            FinancialListBubble(payload: payload)
        case .confirmation(let payload):
            confirmation(payload)
        case .approval(let payload):
            approval(payload)
        case .html(let payload):
            HTMLBubble(payload: payload)
        case .liveAgent(let payload):
            LiveAgentBubble(
                payload: payload,
                onContinue: handlers.onAction,
                onCancel: { handlers.onDeclineLiveAgent(payload) }
            )
        case .choices(let payload):
            choices(payload)
        case .receipt(let payload):
            ReceiptBubble(payload: payload)
        case .status(let payload):
            StatusBubble(payload: payload)
        case .actions(let payload):
            ActionBubble(payload: payload, onAction: handlers.onAction)
        case .unsupported(let message):
            unsupported(message)
        }
    }

    private func unsupported(_ message: String?) -> some View {
        StatusBubble(payload: StatusPayload(
            title: copy.chat("chat.updateRequired"), detail: message ?? copy.chat("chat.unsupported"), level: .warning
        ))
    }

    private func confirmation(_ payload: ConfirmationPayload) -> some View {
        ConfirmationCard(
            title: copy.chat("chat.confirmation"),
            fields: payload.fields.map { KeyValue(label: $0.label, value: $0.value) },
            confirmLabel: copy.chat("chat.confirm"), onConfirm: { handlers.onConfirmation(payload) }
        )
        .accessibilityIdentifier("confirmation.\(payload.confirmationIdentifier)")
    }

    private func approval(_ payload: ApprovalPayload) -> some View {
        ApprovalBubble(
            payload: payload,
            onEdit: { handlers.approval.onEdit(payload) },
            onCancel: { handlers.approval.onCancel(payload) },
            onApprove: { handlers.approval.onApprove(payload) }
        )
    }

    private func answer(_ payload: AnswerPayload) -> some View {
        AnswerView(
            payload: payload,
            onSelect: { handlers.onAnswerOption(viewModel.identifier, $0) },
            onAction: handlers.onAction
        )
    }

    private func choices(_ payload: ChoicesPayload) -> some View {
        ChoicesBubble(
            payload: payload,
            onToggle: { handlers.choices.onToggle(payload, $0) },
            onSubmit: { handlers.choices.onSubmit(payload) }
        )
    }
}
