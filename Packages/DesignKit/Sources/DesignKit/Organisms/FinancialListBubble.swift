import SwiftUI

public struct FinancialListBubble: View {
    let payload: FinancialListPayload
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

    public init(payload: FinancialListPayload) {
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
        .cornerRadius(artwork.size(DesignKitMetrics.Radius.card))
        .frame(maxWidth: artwork.size(DesignKitMetrics.Size.cardMaximumWidth), alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(
            "financialList.\(payload.style.rawValue)"
        )
    }

    private var header: some View {
        HStack(spacing: artwork.size(DesignKitMetrics.Spacing.medium)) {
            Image(systemName: symbolName)
                .designFont(.headline)
                .foregroundColor(iconColor)
                .frame(width: artwork.size(DesignKitMetrics.Size.icon))
            Text(payload.title)
                .designFont(.headline)
                .foregroundColor(Color(theme.colors.primaryText))
        }
        .padding(artwork.size(DesignKitMetrics.Spacing.wide))
    }

    private var rows: some View {
        VStack(spacing: artwork.size(DesignKitMetrics.Spacing.roomy)) {
            ForEach(payload.rows.indices, id: \.self) { index in
                row(payload.rows[index])
            }
        }
        .padding(artwork.size(DesignKitMetrics.Spacing.wide))
    }

    private func row(_ item: FinancialListRow) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: artwork.size(DesignKitMetrics.Spacing.regular)) {
            VStack(alignment: .leading, spacing: artwork.size(DesignKitMetrics.Radius.swatch)) {
                Text(item.title)
                    .designFont(.subheadline)
                optionalText(item.subtitle)
            }
            Spacer(minLength: artwork.size(DesignKitMetrics.Spacing.compact))
            VStack(alignment: .trailing, spacing: artwork.size(DesignKitMetrics.Radius.swatch)) {
                Text(item.value)
                    .designFont(.headline)
                    .foregroundColor(valueColor(item))
                optionalText(item.detail)
            }
        }
    }

    @ViewBuilder
    private func optionalText(_ text: String?) -> some View {
        if let text = text {
            Text(text)
                .designFont(.caption)
                .foregroundColor(Color(theme.colors.secondaryText))
        }
    }

    @ViewBuilder
    private var total: some View {
        if let label = payload.totalLabel, let value = payload.totalValue {
            VStack(spacing: artwork.size(DesignKitMetrics.Spacing.regular)) {
                cardDivider
                HStack(alignment: .firstTextBaseline, spacing: artwork.size(DesignKitMetrics.Spacing.compact)) {
                    Text(label)
                    Spacer(minLength: artwork.size(DesignKitMetrics.Spacing.compact))
                    VStack(alignment: .trailing, spacing: artwork.size(DesignKitMetrics.Spacing.micro)) {
                        Text(value).designFont(.headline)
                        optionalText(payload.totalCaption)
                    }
                }
                .designFont(.subheadline)
                .padding(.horizontal, artwork.size(DesignKitMetrics.Spacing.wide))
            }
        }
    }

    @ViewBuilder
    private var footnote: some View {
        if let footnote = payload.footnote {
            Text(footnote)
                .designFont(.footnote)
                .foregroundColor(Color(theme.colors.secondaryText))
                .padding(artwork.size(DesignKitMetrics.Spacing.wide))
        }
    }

    private var cardDivider: some View {
        Rectangle()
            .fill(Color(theme.colors.divider))
            .frame(height: artwork.stroke(DesignKitMetrics.Stroke.divider))
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

    private func valueColor(_ row: FinancialListRow) -> Color {
        row.tone == .positive
            ? Color(theme.colors.success)
            : Color(theme.colors.primaryText)
    }
}
