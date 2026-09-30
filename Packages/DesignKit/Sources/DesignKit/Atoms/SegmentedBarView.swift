import SwiftUI

struct SegmentedBarView: View {
    let series: [ChartSeries]
    @Environment(\.theme) private var theme

    var body: some View {
        let total = series.reduce(0) { $0 + max(0, $1.value) }
        return GeometryReader { proxy in
            HStack(spacing: 1) {
                ForEach(series.indices, id: \.self) { index in
                    Rectangle()
                        .fill(segmentColor(index))
                        .frame(width: segmentWidth(index, total: total, width: proxy.size.width))
                }
            }
            .clipShape(Capsule())
        }
        .frame(height: 12)
    }

    private func segmentWidth(
        _ index: Int,
        total: Double,
        width: CGFloat
    ) -> CGFloat {
        guard total > 0 else {
            return 0
        }
        let available = max(0, width - CGFloat(max(0, series.count - 1)))
        return available * CGFloat(max(0, series[index].value) / total)
    }

    private func segmentColor(_ index: Int) -> Color {
        let colors = theme.colors.chartColors
        return Color(colors[index % colors.count])
    }
}
