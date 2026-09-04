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
            TanyaAITextBubble(
                text: text,
                isUser: viewModel.role == .user
            )
        case .information(let payload):
            TanyaAIInformationBubble(payload: payload)
        case .chart(let payload):
            TanyaAIChartBubble(payload: payload)
        case .portfolio(let payload):
            TanyaAIPortfolioBubble(payload: payload)
        case .financialList(let payload):
            TanyaAIFinancialListBubble(payload: payload)
        case .approval(let payload):
            TanyaAIApprovalBubble(
                payload: payload,
                onEdit: { handlers.onApprovalEdit(payload) },
                onCancel: { handlers.onApprovalCancel(payload) },
                onApprove: { handlers.onApproval(payload) }
            )
        case .receipt(let payload):
            TanyaAIReceiptBubble(payload: payload)
        case .status(let payload):
            TanyaAIStatusBubble(payload: payload)
        case .actions(let payload):
            TanyaAIActionBubble(payload: payload, onAction: handlers.onAction)
        case .unsupported(let message):
            TanyaAIStatusBubble(
                payload: TanyaAIStatusPayload(
                    title: "Update required",
                    detail: message,
                    level: .warning
                )
            )
        }
    }
}
