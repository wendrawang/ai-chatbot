import SwiftUI

public struct PortfolioBubble: View {
    let payload: PortfolioPayload
    @Environment(\.theme) private var theme

    public init(payload: PortfolioPayload) {
        self.payload = payload
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignKitMetrics.Spacing.section.sizeInArtwork) {
            header
            Text(payload.totalValue)
                .designFont(.amount)
            Text(payload.performanceText)
                .designFont(.headline)
                .foregroundColor(Color(theme.colors.success))
            SegmentedBarView(series: payload.allocations)
            ChartLegendView(series: payload.allocations)
            footnote
        }
        .foregroundColor(Color(theme.colors.primaryText))
        .padding(DesignKitMetrics.Spacing.wide.sizeInArtwork)
        .background(Color(theme.colors.surface))
        .cornerRadius(DesignKitMetrics.Radius.card.sizeInArtwork)
        .frame(maxWidth: DesignKitMetrics.Size.cardMaximumWidth.sizeInArtwork, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("portfolio.summary")
    }

    private var header: some View {
        HStack(spacing: DesignKitMetrics.Spacing.medium.sizeInArtwork) {
            Image(systemName: "chart.bar")
                .designFont(.headline)
                .foregroundColor(Color(theme.colors.accent))
                .frame(width: DesignKitMetrics.Size.icon.sizeInArtwork)
            Text(payload.title)
                .designFont(.headline)
        }
    }

    @ViewBuilder
    private var footnote: some View {
        if let footnote = payload.footnote {
            Text(footnote)
                .designFont(.footnote)
                .foregroundColor(Color(theme.colors.secondaryText))
        }
    }
}
