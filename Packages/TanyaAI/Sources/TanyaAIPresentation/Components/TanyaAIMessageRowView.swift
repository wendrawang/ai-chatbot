import DesignKit
import SwiftUI
import TanyaAIDomain

struct TanyaAIMessageRowView: View {
    @ObservedObject var viewModel: TanyaAIMessageItemViewModel
    let handlers: TanyaAIMessageRowHandlers

    var body: some View {
        HStack {
            if viewModel.role == .user {
                Spacer(minLength: 48)
            }

            content

            if viewModel.role != .user {
                Spacer(minLength: 32)
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
            ChoicesBubble(
                payload: payload,
                onToggle: { handlers.choices.onToggle(payload, $0) },
                onSubmit: { handlers.choices.onSubmit(payload) }
            )
        case .receipt(let payload):
            ReceiptBubble(payload: payload)
        case .status(let payload):
            StatusBubble(payload: payload)
        case .actions(let payload):
            ActionBubble(payload: payload, onAction: handlers.onAction)
        case .unsupported(let message):
            StatusBubble(
                payload: StatusPayload(
                    title: "Update required",
                    detail: message,
                    level: .warning
                )
            )
        }
    }

    private func approval(_ payload: ApprovalPayload) -> some View {
        ApprovalBubble(
            payload: payload,
            onEdit: { handlers.approval.onEdit(payload) },
            onCancel: { handlers.approval.onCancel(payload) },
            onApprove: { handlers.approval.onApprove(payload) }
        )
    }
}
