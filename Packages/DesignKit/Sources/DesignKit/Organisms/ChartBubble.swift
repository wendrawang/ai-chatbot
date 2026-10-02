import SwiftUI

public struct ChartBubble: View {
    let payload: ChartPayload
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

    public init(payload: ChartPayload) {
        self.payload = payload
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: artwork.size(DesignKitMetrics.Spacing.section)) {
            header
            total
            ChartGraphic(type: payload.chartType, series: payload.series)
            ChartLegendView(series: payload.series)
            footnote
        }
        .foregroundColor(Color(theme.colors.primaryText))
        .padding(artwork.size(DesignKitMetrics.Spacing.wide))
        .background(Color(theme.colors.surface))
        .cornerRadius(artwork.size(DesignKitMetrics.Radius.card))
        .frame(maxWidth: artwork.size(DesignKitMetrics.Size.cardMaximumWidth), alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(
            "content.chart.\(payload.chartType.rawValue)"
        )
    }

    private var header: some View {
        HStack(spacing: artwork.size(DesignKitMetrics.Spacing.medium)) {
            Image(systemName: "chart.pie")
                .designFont(.headline)
                .foregroundColor(Color(theme.colors.accent))
                .frame(width: artwork.size(DesignKitMetrics.Size.icon))
            Text(payload.title)
                .designFont(.headline)
        }
    }

    @ViewBuilder
    private var total: some View {
        if let totalValue = payload.totalValue {
            VStack(alignment: .leading, spacing: artwork.size(DesignKitMetrics.Spacing.tight)) {
                Text(totalValue)
                    .designFont(.amount)
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
                .designFont(.subheadline)
                .foregroundColor(Color(theme.colors.secondaryText))
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
