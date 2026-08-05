import SwiftUI
import TanyaAIDomain

struct TanyaAIReceiptBubble: View {
    let payload: TanyaAIReceiptPayload
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        VStack(spacing: 16) {
            successHeader
            summary
            footnote
        }
        .padding(18)
        .background(theme.colors.surface)
        .cornerRadius(18)
        .frame(maxWidth: 340, alignment: .leading)
        .accessibilityElement(children: .contain)
        .tanyaAIAccessibilityIdentifier("receipt.success")
    }

    private var successHeader: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark")
                .font(theme.fonts.title)
                .foregroundColor(theme.colors.success)
                .frame(width: 64, height: 64)
                .background(theme.colors.success.opacity(0.12))
                .clipShape(Circle())
            Text(payload.title)
                .font(theme.fonts.title)
                .multilineTextAlignment(.center)
            Text(payload.detail)
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var summary: some View {
        VStack(spacing: 12) {
            Rectangle()
                .fill(theme.colors.divider)
                .frame(height: 0.5)
            ForEach(payload.summary.indices, id: \.self) { index in
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(payload.summary[index].label)
                        .foregroundColor(theme.colors.secondaryText)
                    Spacer(minLength: 8)
                    Text(payload.summary[index].value)
                        .font(theme.fonts.headline)
                        .multilineTextAlignment(.trailing)
                }
                .font(theme.fonts.subheadline)
            }
        }
    }

    @ViewBuilder
    private var footnote: some View {
        if let footnote = payload.footnote {
            Text(footnote)
                .font(theme.fonts.footnote)
                .foregroundColor(theme.colors.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
