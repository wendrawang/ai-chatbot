import SwiftUI

public struct ChartBubble: View {
    let payload: ChartPayload
    @Environment(\.theme) private var theme

    public init(payload: ChartPayload) {
        self.payload = payload
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            header
            total
            SegmentedBarView(series: payload.series)
            ChartLegendView(series: payload.series)
            footnote
        }
        .padding(DesignKitMetrics.Spacing.wide)
        .background(Color(theme.colors.surface))
        .cornerRadius(DesignKitMetrics.Radius.card)
        .frame(maxWidth: 340, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(
            "content.chart.\(payload.chartType.rawValue)"
        )
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "chart.pie")
                .font(Font(theme.fonts.headline))
                .foregroundColor(Color(theme.colors.accent))
                .frame(width: 24)
            Text(payload.title)
                .font(Font(theme.fonts.headline))
        }
    }

    @ViewBuilder
    private var total: some View {
        if let totalValue = payload.totalValue {
            VStack(alignment: .leading, spacing: DesignKitMetrics.Spacing.tight) {
                Text(totalValue)
                    .font(Font(theme.fonts.amount))
                subtitle
            }
        } else {
            subtitle
        }
    }

    @ViewBuilder
    private var subtitle: some View {
        if let subtitle = payload.subtitle {
            Text(subtitle)
                .font(Font(theme.fonts.subheadline))
                .foregroundColor(Color(theme.colors.secondaryText))
        }
    }

    @ViewBuilder
    private var footnote: some View {
        if let footnote = payload.footnote {
            Text(footnote)
                .font(Font(theme.fonts.footnote))
                .foregroundColor(Color(theme.colors.secondaryText))
        }
    }
}
