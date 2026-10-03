import SwiftUI

struct SegmentedBarView: View {
    let series: [ChartSeries]
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

    var body: some View {
        let fractions = ChartGeometry.fractions(series.map(\.value))
        return GeometryReader { proxy in
            HStack(spacing: artwork.size(DesignKitMetrics.Spacing.pixelGap)) {
                ForEach(series.indices, id: \.self) { index in
                    Rectangle()
                        .fill(segmentColor(index))
                        .frame(width: segmentWidth(fractions[index], width: proxy.size.width))
                }
            }
            .clipShape(Capsule())
        }
        .frame(height: artwork.size(DesignKitMetrics.Spacing.regular))
    }

    private func segmentWidth(
        _ fraction: Double,
        width: CGFloat
    ) -> CGFloat {
        guard fraction > 0 else {
            return 0
        }
        let gaps = CGFloat(max(0, series.count - 1)) * artwork.size(DesignKitMetrics.Spacing.pixelGap)
        let available = max(0, width - gaps)
        return available * CGFloat(fraction)
    }

    private func segmentColor(_ index: Int) -> Color {
        let colors = theme.colors.chartColors
        return Color(colors.isEmpty ? theme.colors.accent : colors[index % colors.count])
    }
}
