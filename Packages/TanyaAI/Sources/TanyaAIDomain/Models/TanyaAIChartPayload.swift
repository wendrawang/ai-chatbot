public struct TanyaAIChartPayload: Equatable {
    public enum ChartType: String, Equatable {
        case bar
        case line
        case donut
        case progress
    }

    public let title: String
    public let subtitle: String?
    public let totalValue: String?
    public let chartType: ChartType
    public let series: [TanyaAIChartSeries]
    public let footnote: String?

    public init(
        title: String,
        subtitle: String?,
        totalValue: String? = nil,
        chartType: ChartType,
        series: [TanyaAIChartSeries],
        footnote: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.totalValue = totalValue
        self.chartType = chartType
        self.series = series
        self.footnote = footnote
    }
}

public struct TanyaAIChartSeries: Equatable {
    public let label: String
    public let value: Double
    public let formattedValue: String

    public init(
        label: String,
        value: Double,
        formattedValue: String
    ) {
        self.label = label
        self.value = value
        self.formattedValue = formattedValue
    }
}
