import DesignKit

public enum TanyaAIMessageContent: Equatable {
    case text(String)
    case image(ImagePayload)
    case choices(ChoicesPayload)
    case liveAgent(LiveAgentPayload)
    case information(InformationPayload)
    case chart(ChartPayload)
    case portfolio(PortfolioPayload)
    case financialList(FinancialListPayload)
    case approval(ApprovalPayload)
    case receipt(ReceiptPayload)
    case status(StatusPayload)
    case actions(ActionPayload)
    case unsupported(String)
}
