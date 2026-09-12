import SwiftUI

public struct TanyaAIFinancialListBubble: View {
    let payload: TanyaAIFinancialListPayload
    @Environment(\.tanyaAITheme) private var theme

    public init(payload: TanyaAIFinancialListPayload) {
        self.payload = payload
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            cardDivider
            rows
            total
            footnote
        }
        .background(Color(theme.colors.surface))
        .cornerRadius(DesignKitMetrics.Radius.card)
        .frame(maxWidth: 340, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(
            "financialList.\(payload.style.rawValue)"
        )
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: symbolName)
                .font(Font(theme.fonts.headline))
                .foregroundColor(iconColor)
                .frame(width: 24)
            Text(payload.title)
                .font(Font(theme.fonts.headline))
                .foregroundColor(Color(theme.colors.primaryText))
        }
        .padding(DesignKitMetrics.Spacing.wide)
    }

    private var rows: some View {
        VStack(spacing: DesignKitMetrics.Spacing.roomy) {
            ForEach(payload.rows.indices, id: \.self) { index in
                row(payload.rows[index])
            }
        }
        .padding(DesignKitMetrics.Spacing.wide)
    }

    private func row(_ item: TanyaAIFinancialListRow) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: DesignKitMetrics.Spacing.regular) {
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(Font(theme.fonts.subheadline))
                optionalText(item.subtitle)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 3) {
                Text(item.value)
                    .font(Font(theme.fonts.headline))
                    .foregroundColor(valueColor(item))
                optionalText(item.detail)
            }
        }
    }

    @ViewBuilder
    private func optionalText(_ text: String?) -> some View {
        if let text = text {
            Text(text)
                .font(Font(theme.fonts.caption))
                .foregroundColor(Color(theme.colors.secondaryText))
        }
    }

    @ViewBuilder
    private var total: some View {
        if let label = payload.totalLabel, let value = payload.totalValue {
            VStack(spacing: DesignKitMetrics.Spacing.regular) {
                cardDivider
                HStack(alignment: .firstTextBaseline) {
                    Text(label)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(value).font(Font(theme.fonts.headline))
                        optionalText(payload.totalCaption)
                    }
                }
                .font(Font(theme.fonts.subheadline))
                .padding(.horizontal, DesignKitMetrics.Spacing.wide)
            }
        }
    }

    @ViewBuilder
    private var footnote: some View {
        if let footnote = payload.footnote {
            Text(footnote)
                .font(Font(theme.fonts.footnote))
                .foregroundColor(Color(theme.colors.secondaryText))
                .padding(DesignKitMetrics.Spacing.wide)
        }
    }

    private var cardDivider: some View {
        Rectangle()
            .fill(Color(theme.colors.divider))
            .frame(height: 0.5)
    }

    private var symbolName: String {
        switch payload.style {
        case .paidBills: return "doc.text"
        case .incoming: return "arrow.down"
        case .holdings: return "chart.line.uptrend.xyaxis"
        }
    }

    private var iconColor: Color {
        payload.style == .incoming
            ? Color(theme.colors.success)
            : Color(theme.colors.accent)
    }

    private func valueColor(_ row: TanyaAIFinancialListRow) -> Color {
        row.tone == .positive
            ? Color(theme.colors.success)
            : Color(theme.colors.primaryText)
    }
}
