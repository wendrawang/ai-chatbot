import SwiftUI
import TanyaAIDomain

struct TanyaAIPortfolioBubble: View {
    let payload: TanyaAIPortfolioPayload
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            header
            Text(payload.totalValue)
                .font(theme.fonts.amount)
            Text(payload.performanceText)
                .font(theme.fonts.headline)
                .foregroundColor(theme.colors.success)
            TanyaAISegmentedBarView(series: payload.allocations)
            TanyaAIChartLegendView(series: payload.allocations)
            footnote
        }
        .padding(16)
        .background(theme.colors.surface)
        .cornerRadius(18)
        .frame(maxWidth: 340, alignment: .leading)
        .accessibilityElement(children: .contain)
        .tanyaAIAccessibilityIdentifier("portfolio.summary")
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "chart.bar")
                .font(theme.fonts.headline)
                .foregroundColor(theme.colors.accent)
                .frame(width: 24)
            Text(payload.title)
                .font(theme.fonts.headline)
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
