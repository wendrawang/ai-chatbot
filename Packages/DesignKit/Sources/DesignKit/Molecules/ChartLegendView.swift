import SwiftUI

/// A chart's key: one swatch, one label, one value per series.
///
/// A molecule rather than an atom - it is rows of smaller parts, and it
/// only means anything next to the chart it explains.
struct ChartLegendView: View {
    let series: [ChartSeries]
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: DesignKitMetrics.Spacing.legend.sizeInArtwork) {
            ForEach(series.indices, id: \.self) { index in
                HStack(spacing: DesignKitMetrics.Spacing.legend.sizeInArtwork) {
                    RoundedRectangle(cornerRadius: DesignKitMetrics.Radius.swatch.sizeInArtwork)
                        .fill(segmentColor(index))
                        .frame(
                            width: DesignKitMetrics.Spacing.regular.sizeInArtwork,
                            height: DesignKitMetrics.Spacing.regular.sizeInArtwork
                        )
                    Text(series[index].label)
                        .designFont(.subheadline)
                    Spacer(minLength: DesignKitMetrics.Spacing.compact.sizeInArtwork)
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
