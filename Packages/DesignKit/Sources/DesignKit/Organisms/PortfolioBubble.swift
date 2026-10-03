import SwiftUI

public struct PortfolioBubble: View {
    let payload: PortfolioPayload
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

    public init(payload: PortfolioPayload) {
        self.payload = payload
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: artwork.size(DesignKitMetrics.Spacing.section)) {
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
        .padding(artwork.size(DesignKitMetrics.Spacing.wide))
        .background(Color(theme.colors.surface))
        .cornerRadius(artwork.size(DesignKitMetrics.Radius.card))
        .frame(maxWidth: artwork.size(DesignKitMetrics.Size.cardMaximumWidth), alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("portfolio.summary")
    }

    private var header: some View {
        HStack(spacing: artwork.size(DesignKitMetrics.Spacing.medium)) {
            Image(systemName: "chart.bar")
                .designFont(.headline)
                .foregroundColor(Color(theme.colors.accent))
                .frame(width: artwork.size(DesignKitMetrics.Size.icon))
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
