import SwiftUI

struct TanyaAISegmentedBarView: View {
    let series: [TanyaAIChartSeries]
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 1) {
                ForEach(series.indices, id: \.self) { index in
                    Rectangle()
                        .fill(segmentColor(index))
                        .frame(width: segmentWidth(index, proxy: proxy))
                }
            }
            .clipShape(Capsule())
        }
        .frame(height: 12)
    }

    private func segmentWidth(
        _ index: Int,
        proxy: GeometryProxy
    ) -> CGFloat {
        let total = series.reduce(0) { $0 + max(0, $1.value) }
        guard total > 0 else {
            return 0
        }
        let available = proxy.size.width - CGFloat(max(0, series.count - 1))
        return available * CGFloat(max(0, series[index].value) / total)
    }

    private func segmentColor(_ index: Int) -> Color {
        let colors = theme.colors.chartColors
        return Color(colors[index % colors.count])
    }
}
