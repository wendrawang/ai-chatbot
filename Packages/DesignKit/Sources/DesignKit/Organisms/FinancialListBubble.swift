import SwiftUI

public struct FinancialListBubble: View {
    let payload: FinancialListPayload
    @Environment(\.theme) private var theme

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
        .cornerRadius(DesignKitMetrics.Radius.card.sizeInArtwork)
        .frame(maxWidth: DesignKitMetrics.Size.cardMaximumWidth.sizeInArtwork, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(
            "financialList.\(payload.style.rawValue)"
        )
    }

    private var header: some View {
        HStack(spacing: DesignKitMetrics.Spacing.medium.sizeInArtwork) {
            Image(systemName: symbolName)
                .designFont(.headline)
                .foregroundColor(iconColor)
                .frame(width: DesignKitMetrics.Size.icon.sizeInArtwork)
            Text(payload.title)
                .designFont(.headline)
                .foregroundColor(Color(theme.colors.primaryText))
        }
        .padding(FigmaSize.spacing16.sizeInArtwork)
    }

    private var rows: some View {
        VStack(spacing: DesignKitMetrics.Spacing.roomy.sizeInArtwork) {
            ForEach(payload.rows.indices, id: \.self) { index in
                row(payload.rows[index])
            }
        }
        .padding(FigmaSize.spacing16.sizeInArtwork)
    }

    private func row(_ item: FinancialListRow) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: DesignKitMetrics.Spacing.regular.sizeInArtwork) {
            VStack(alignment: .leading, spacing: DesignKitMetrics.Radius.swatch.sizeInArtwork) {
                Text(item.title)
                    .designFont(.subheadline)
                optionalText(item.subtitle)
            }
            Spacer(minLength: FigmaSize.spacing8.sizeInArtwork)
            VStack(alignment: .trailing, spacing: DesignKitMetrics.Radius.swatch.sizeInArtwork) {
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
            VStack(spacing: DesignKitMetrics.Spacing.regular.sizeInArtwork) {
                cardDivider
                HStack(alignment: .firstTextBaseline, spacing: FigmaSize.spacing8.sizeInArtwork) {
                    Text(label)
                    Spacer(minLength: FigmaSize.spacing8.sizeInArtwork)
                    VStack(alignment: .trailing, spacing: DesignKitMetrics.Spacing.micro.sizeInArtwork) {
                        Text(value).designFont(.headline)
                        optionalText(payload.totalCaption)
                    }
                }
                .designFont(.subheadline)
                .padding(.horizontal, FigmaSize.spacing16.sizeInArtwork)
            }
        }
    }

    @ViewBuilder
    private var footnote: some View {
        if let footnote = payload.footnote {
            Text(footnote)
                .designFont(.footnote)
                .foregroundColor(Color(theme.colors.secondaryText))
                .padding(FigmaSize.spacing16.sizeInArtwork)
        }
    }

    private var cardDivider: some View {
        Rectangle()
            .fill(Color(theme.colors.divider))
            .frame(height: DesignKitMetrics.Stroke.divider.strokeInArtwork)
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
