public struct TanyaAIPortfolioPayload: Equatable {
    public let title: String
    public let totalValue: String
    public let performanceText: String
    public let allocations: [TanyaAIChartSeries]
    public let footnote: String?

    public init(
        title: String,
        totalValue: String,
        performanceText: String,
        allocations: [TanyaAIChartSeries],
        footnote: String? = nil
    ) {
        self.title = title
        self.totalValue = totalValue
        self.performanceText = performanceText
        self.allocations = allocations
        self.footnote = footnote
    }
}
