import SwiftUI

/// A chart's key: one swatch, one label, one value per series.
///
/// A molecule rather than an atom - it is rows of smaller parts, and it
/// only means anything next to the chart it explains.
struct ChartLegendView: View {
    let series: [ChartSeries]
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

    var body: some View {
        VStack(spacing: artwork.size(DesignKitMetrics.Spacing.legend)) {
            ForEach(series.indices, id: \.self) { index in
                HStack(spacing: artwork.size(DesignKitMetrics.Spacing.legend)) {
                    RoundedRectangle(cornerRadius: artwork.size(DesignKitMetrics.Radius.swatch))
                        .fill(segmentColor(index))
                        .frame(
                            width: artwork.size(DesignKitMetrics.Spacing.regular),
                            height: artwork.size(DesignKitMetrics.Spacing.regular)
                        )
                    Text(series[index].label)
                        .designFont(.subheadline)
                    Spacer(minLength: artwork.size(DesignKitMetrics.Spacing.compact))
                    Text(series[index].formattedValue)
                        .designFont(.headline)
                }
                .accessibilityElement(children: .ignore)
                .accessibility(
                    label: Text(
                        "\(series[index].label), "
                            + series[index].formattedValue
                    )
                )
            }
        }
        .foregroundColor(Color(theme.colors.primaryText))
    }

    private func segmentColor(_ index: Int) -> Color {
        let colors = theme.colors.chartColors
        return Color(colors.isEmpty ? theme.colors.accent : colors[index % colors.count])
    }
}
