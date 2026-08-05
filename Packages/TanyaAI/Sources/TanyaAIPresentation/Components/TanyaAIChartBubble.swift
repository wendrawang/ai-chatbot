import SwiftUI
import TanyaAIDomain

struct TanyaAIChartBubble: View {
    let payload: TanyaAIChartPayload
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            header
            total
            TanyaAISegmentedBarView(series: payload.series)
            TanyaAIChartLegendView(series: payload.series)
            footnote
        }
        .padding(16)
        .background(theme.colors.surface)
        .cornerRadius(18)
        .frame(maxWidth: 340, alignment: .leading)
        .accessibilityElement(children: .contain)
        .tanyaAIAccessibilityIdentifier(
            "content.chart.\(payload.chartType.rawValue)"
        )
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "chart.pie")
                .font(theme.fonts.headline)
                .foregroundColor(theme.colors.accent)
                .frame(width: 24)
            Text(payload.title)
                .font(theme.fonts.headline)
        }
    }

    @ViewBuilder
    private var total: some View {
        if let totalValue = payload.totalValue {
            VStack(alignment: .leading, spacing: 4) {
                Text(totalValue)
                    .font(theme.fonts.amount)
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
                .font(theme.fonts.subheadline)
                .foregroundColor(theme.colors.secondaryText)
        }
    }

    @ViewBuilder
    private var footnote: some View {
        if let footnote = payload.footnote {
            Text(footnote)
                .font(theme.fonts.footnote)
                .foregroundColor(theme.colors.secondaryText)
        }
    }
}
