import SwiftUI
import TanyaAIDomain

struct TanyaAIChartBubble: View {
    let payload: TanyaAIChartPayload
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(payload.title)
                .font(Font(theme.fonts.headline))

            if let subtitle = payload.subtitle {
                Text(subtitle)
                    .font(Font(theme.fonts.subheadline))
                    .foregroundColor(Color(theme.colors.secondaryText))
            }

            TanyaAIBarChartView(series: payload.series)
        }
        .padding(16)
        .background(Color(theme.colors.surface))
        .cornerRadius(16)
        .frame(maxWidth: 340, alignment: .leading)
    }
}

struct TanyaAIBarChartView: View {
    let series: [TanyaAIChartSeries]
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        VStack(spacing: 10) {
            ForEach(series.indices, id: \.self) { index in
                row(series[index])
            }
        }
    }

    private func row(_ item: TanyaAIChartSeries) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.label)
                Spacer()
                Text(item.formattedValue)
                    .fontWeight(.semibold)
            }
            .font(Font(theme.fonts.caption))

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(theme.colors.chartTrack))
                    Capsule()
                        .fill(Color(theme.colors.accent))
                        .frame(width: barWidth(item, available: proxy.size.width))
                }
            }
            .frame(height: 8)
        }
        .accessibilityElement(children: .ignore)
        .accessibility(
            label: Text("\(item.label), \(item.formattedValue)")
        )
    }

    private func barWidth(
        _ item: TanyaAIChartSeries,
        available: CGFloat
    ) -> CGFloat {
        let maximum = series.map { $0.value }.max() ?? 1
        guard maximum > 0 else {
            return 0
        }
        return available * CGFloat(max(0, item.value) / maximum)
    }
}
