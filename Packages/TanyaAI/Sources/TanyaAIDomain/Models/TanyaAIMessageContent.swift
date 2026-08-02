public enum TanyaAIMessageContent: Equatable {
    case text(String)
    case information(TanyaAIInformationPayload)
    case chart(TanyaAIChartPayload)
    case portfolio(TanyaAIPortfolioPayload)
    case approval(TanyaAIApprovalPayload)
    case status(TanyaAIStatusPayload)
    case unsupported(String)
}
