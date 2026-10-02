import SwiftUI

/// Decorative geometry; the adjacent legend provides the accessible values.
struct ChartGraphic: View {
    let type: ChartPayload.ChartType
    let series: [ChartSeries]
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

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
            HStack(alignment: .bottom, spacing: artwork.size(DesignKitMetrics.Spacing.compact)) {
                ForEach(values.indices, id: \.self) { index in
                    Rectangle()
                        .fill(color(index))
                        .frame(height: maximum > 0 ? proxy.size.height * (values[index] / maximum) : 0)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
        }
        .frame(height: artwork.size(DesignKitMetrics.Size.chartHeight))
    }

    private var donut: some View {
        let fractions = ChartGeometry.fractions(series.map(\.value))
        let ends = fractions.reduce(into: [Double](arrayLiteral: 0)) { $0.append(($0.last ?? 0) + $1) }
        return ZStack {
            ForEach(fractions.indices, id: \.self) { index in
                Circle()
                    .trim(from: ends[index], to: ends[index + 1])
                    .stroke(color(index), lineWidth: artwork.size(DesignKitMetrics.Size.chartRing))
                    .rotationEffect(.degrees(-90))
            }
        }
        .padding(artwork.size(DesignKitMetrics.Size.chartRing) / 2)
        .frame(height: artwork.size(DesignKitMetrics.Size.chartHeight))
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
                .stroke(Color(theme.colors.accent), lineWidth: artwork.stroke(DesignKitMetrics.Stroke.chart))
                ForEach(values.indices, id: \.self) { index in
                    Circle()
                        .fill(Color(theme.colors.accent))
                        .frame(
                            width: artwork.size(DesignKitMetrics.Size.dot),
                            height: artwork.size(DesignKitMetrics.Size.dot)
                        )
                        .position(point(index, values: values, size: proxy.size))
                }
            }
        }
        .padding(artwork.size(DesignKitMetrics.Spacing.tight))
        .frame(height: artwork.size(DesignKitMetrics.Size.chartHeight))
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
