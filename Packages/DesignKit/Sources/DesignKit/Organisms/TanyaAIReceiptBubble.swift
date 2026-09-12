import SwiftUI

public struct TanyaAIReceiptBubble: View {
    let payload: TanyaAIReceiptPayload
    @Environment(\.tanyaAITheme) private var theme

    public init(payload: TanyaAIReceiptPayload) {
        self.payload = payload
    }

    public var body: some View {
        VStack(spacing: 16) {
            successHeader
            summary
            footnote
        }
        .padding(DesignKitMetrics.Spacing.card)
        .background(Color(theme.colors.surface))
        .cornerRadius(DesignKitMetrics.Radius.card)
        .frame(maxWidth: 340, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("receipt.success")
    }

    private var successHeader: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark")
                .font(Font(theme.fonts.title))
                .foregroundColor(Color(theme.colors.success))
                .frame(width: 64, height: 64)
                .background(Color(theme.colors.success).opacity(0.12))
                .clipShape(Circle())
            Text(payload.title)
                .font(Font(theme.fonts.title))
                .multilineTextAlignment(.center)
            Text(payload.detail)
                .font(Font(theme.fonts.body))
                .foregroundColor(Color(theme.colors.secondaryText))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var summary: some View {
        VStack(spacing: DesignKitMetrics.Spacing.regular) {
            Rectangle()
                .fill(Color(theme.colors.divider))
                .frame(height: 0.5)
            ForEach(payload.summary.indices, id: \.self) { index in
                HStack(alignment: .firstTextBaseline, spacing: DesignKitMetrics.Spacing.regular) {
                    Text(payload.summary[index].label)
                        .foregroundColor(Color(theme.colors.secondaryText))
                    Spacer(minLength: 8)
                    Text(payload.summary[index].value)
                        .font(Font(theme.fonts.headline))
                        .multilineTextAlignment(.trailing)
                }
                .font(Font(theme.fonts.subheadline))
            }
        }
    }

    @ViewBuilder
    private var footnote: some View {
        if let footnote = payload.footnote {
            Text(footnote)
                .font(Font(theme.fonts.footnote))
                .foregroundColor(Color(theme.colors.secondaryText))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
