import SwiftUI

/// A chart's key: one swatch, one label, one value per series.
///
/// A molecule rather than an atom - it is rows of smaller parts, and it
/// only means anything next to the chart it explains.
struct ChartLegendView: View {
    let series: [ChartSeries]
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: 9) {
            ForEach(series.indices, id: \.self) { index in
                HStack(spacing: 9) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(segmentColor(index))
                        .frame(width: 12, height: 12)
                    Text(series[index].label)
                        .font(Font(theme.fonts.subheadline))
                    Spacer(minLength: 8)
                    Text(series[index].formattedValue)
                        .font(Font(theme.fonts.headline))
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
    }

    private func segmentColor(_ index: Int) -> Color {
        let colors = theme.colors.chartColors
        return Color(colors[index % colors.count])
    }
}
