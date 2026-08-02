public struct TanyaAIChartPayload: Equatable {
    public enum ChartType: String, Equatable {
        case bar
        case line
        case donut
        case progress
    }

    public let title: String
    public let subtitle: String?
    public let chartType: ChartType
    public let series: [TanyaAIChartSeries]

    public init(
        title: String,
        subtitle: String?,
        chartType: ChartType,
        series: [TanyaAIChartSeries]
    ) {
        self.title = title
        self.subtitle = subtitle
        self.chartType = chartType
        self.series = series
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
