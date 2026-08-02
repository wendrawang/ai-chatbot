public struct TanyaAIPortfolioPayload: Equatable {
    public let title: String
    public let totalValue: String
    public let performanceText: String
    public let allocations: [TanyaAIChartSeries]

    public init(
        title: String,
        totalValue: String,
        performanceText: String,
        allocations: [TanyaAIChartSeries]
    ) {
        self.title = title
        self.totalValue = totalValue
        self.performanceText = performanceText
        self.allocations = allocations
    }
}
