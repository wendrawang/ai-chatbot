public enum TanyaAIMessageContent: Equatable {
    case text(String)
    case information(TanyaAIInformationPayload)
    case chart(TanyaAIChartPayload)
    case portfolio(TanyaAIPortfolioPayload)
    case financialList(TanyaAIFinancialListPayload)
    case approval(TanyaAIApprovalPayload)
    case receipt(TanyaAIReceiptPayload)
    case status(TanyaAIStatusPayload)
    case actions(TanyaAIActionPayload)
    case unsupported(String)
}
