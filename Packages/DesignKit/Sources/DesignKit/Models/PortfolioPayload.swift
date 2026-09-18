public struct PortfolioPayload: Equatable {
    public let title: String
    public let totalValue: String
    public let performanceText: String
    public let allocations: [ChartSeries]
    public let footnote: String?

    public init(
        title: String,
        totalValue: String,
        performanceText: String,
        allocations: [ChartSeries],
        footnote: String? = nil
    ) {
        self.title = title
        self.totalValue = totalValue
        self.performanceText = performanceText
        self.allocations = allocations
        self.footnote = footnote
    }
}
