import SwiftUI
import TanyaAIDomain

struct TanyaAIPortfolioBubble: View {
    let payload: TanyaAIPortfolioPayload
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(payload.title)
                .font(Font(theme.fonts.headline))

            Text(payload.totalValue)
                .font(Font(theme.fonts.amount))

            Text(payload.performanceText)
                .font(Font(theme.fonts.subheadline))
                .foregroundColor(Color(theme.colors.success))

            Rectangle()
                .fill(Color(theme.colors.divider))
                .frame(height: 0.5)

            TanyaAIBarChartView(series: payload.allocations)
        }
        .padding(16)
        .background(Color(theme.colors.surface))
        .cornerRadius(16)
        .frame(maxWidth: 340, alignment: .leading)
        .accessibilityElement(children: .contain)
    }
}
