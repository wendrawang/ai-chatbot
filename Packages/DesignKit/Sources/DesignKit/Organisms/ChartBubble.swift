import SwiftUI

public struct ChartBubble: View {
    let payload: ChartPayload
    @Environment(\.theme) private var theme

    public init(payload: ChartPayload) {
        self.payload = payload
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignKitMetrics.Spacing.section.sizeInArtwork) {
            header
            total
            ChartGraphic(type: payload.chartType, series: payload.series)
            ChartLegendView(series: payload.series)
            footnote
        }
        .foregroundColor(Color(theme.colors.primaryText))
        .padding(FigmaSize.spacing16.sizeInArtwork)
        .background(Color(theme.colors.surface))
        .cornerRadius(DesignKitMetrics.Radius.card.sizeInArtwork)
        .frame(maxWidth: DesignKitMetrics.Size.cardMaximumWidth.sizeInArtwork, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(
            "content.chart.\(payload.chartType.rawValue)"
        )
    }

    private var header: some View {
        HStack(spacing: DesignKitMetrics.Spacing.medium.sizeInArtwork) {
            Image(systemName: "chart.pie")
                .designFont(.headline)
                .foregroundColor(Color(theme.colors.accent))
                .frame(width: DesignKitMetrics.Size.icon.sizeInArtwork)
            Text(payload.title)
                .designFont(.headline)
        }
    }

    @ViewBuilder
    private var total: some View {
        if let totalValue = payload.totalValue {
            VStack(alignment: .leading, spacing: FigmaSize.spacing4.sizeInArtwork) {
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
