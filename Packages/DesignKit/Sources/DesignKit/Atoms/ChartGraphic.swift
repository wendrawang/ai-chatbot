import SwiftUI

/// Decorative geometry; the adjacent legend provides the accessible values.
struct ChartGraphic: View {
    let type: ChartPayload.ChartType
    let series: [ChartSeries]
    @Environment(\.theme) private var theme

    var body: some View {
        Group {
            switch type {
            case .progress:
                SegmentedBarView(series: series)
            case .bar:
                bars
            case .donut:
                donut
            case .line:
                line
            }
        }
        .accessibilityHidden(true)
    }

    private var bars: some View {
        let values = series.map { $0.value.isFinite ? max(0, $0.value) : 0 }
        let maximum = values.max() ?? 0
        return GeometryReader { proxy in
            HStack(alignment: .bottom, spacing: DesignKitMetrics.Spacing.compact.sizeInArtwork) {
                ForEach(values.indices, id: \.self) { index in
                    Rectangle()
                        .fill(color(index))
                        .frame(height: maximum > 0 ? proxy.size.height * (values[index] / maximum) : 0)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
        }
        .frame(height: DesignKitMetrics.Size.chartHeight.sizeInArtwork)
    }

    private var donut: some View {
        let fractions = ChartGeometry.fractions(series.map(\.value))
        let ends = fractions.reduce(into: [Double](arrayLiteral: 0)) { $0.append(($0.last ?? 0) + $1) }
        return ZStack {
            ForEach(fractions.indices, id: \.self) { index in
                Circle()
                    .trim(from: ends[index], to: ends[index + 1])
                    .stroke(color(index), lineWidth: DesignKitMetrics.Size.chartRing.sizeInArtwork)
                    .rotationEffect(.degrees(-90))
            }
        }
        .padding(DesignKitMetrics.Size.chartRing.sizeInArtwork / 2)
        .frame(height: DesignKitMetrics.Size.chartHeight.sizeInArtwork)
        .frame(maxWidth: .infinity)
    }

    private var line: some View {
        let values = ChartGeometry.lineHeights(series.map(\.value))
        return GeometryReader { proxy in
            ZStack {
                Path { path in
                    for index in values.indices {
                        let point = point(index, values: values, size: proxy.size)
                        if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
                    }
                }
                .stroke(Color(theme.colors.accent), lineWidth: DesignKitMetrics.Stroke.chart.strokeInArtwork)
                ForEach(values.indices, id: \.self) { index in
                    Circle()
                        .fill(Color(theme.colors.accent))
                        .frame(
                            width: DesignKitMetrics.Size.dot.sizeInArtwork,
                            height: DesignKitMetrics.Size.dot.sizeInArtwork
                        )
                        .position(point(index, values: values, size: proxy.size))
                }
            }
        }
        .padding(DesignKitMetrics.Spacing.tight.sizeInArtwork)
        .frame(height: DesignKitMetrics.Size.chartHeight.sizeInArtwork)
    }

    private func point(_ index: Int, values: [Double], size: CGSize) -> CGPoint {
        CGPoint(
            x: values.count == 1 ? size.width / 2 : size.width * CGFloat(index) / CGFloat(values.count - 1),
            y: size.height * (1 - values[index])
        )
    }

    private func color(_ index: Int) -> Color {
        let palette = theme.colors.chartColors
        return Color(palette.isEmpty ? theme.colors.accent : palette[index % palette.count])
    }
}
