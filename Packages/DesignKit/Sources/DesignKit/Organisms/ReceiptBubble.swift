import SwiftUI

public struct ReceiptBubble: View {
    let payload: ReceiptPayload
    @Environment(\.theme) private var theme

    public init(payload: ReceiptPayload) {
        self.payload = payload
    }

    public var body: some View {
        VStack(spacing: DesignKitMetrics.Spacing.wide.sizeInArtwork) {
            successHeader
            summary
            footnote
        }
        .foregroundColor(Color(theme.colors.primaryText))
        .padding(DesignKitMetrics.Spacing.card.sizeInArtwork)
        .background(Color(theme.colors.surface))
        .cornerRadius(DesignKitMetrics.Radius.card.sizeInArtwork)
        .frame(maxWidth: DesignKitMetrics.Size.cardMaximumWidth.sizeInArtwork, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("receipt.success")
    }

    private var successHeader: some View {
        VStack(spacing: DesignKitMetrics.Spacing.medium.sizeInArtwork) {
            Image(systemName: "checkmark")
                .designFont(.title)
                .foregroundColor(Color(theme.colors.success))
                .frame(
                            width: DesignKitMetrics.Size.successIcon.sizeInArtwork,
                            height: DesignKitMetrics.Size.successIcon.sizeInArtwork
                        )
                .background(Color(theme.colors.success).opacity(0.12))
                .clipShape(Circle())
            Text(payload.title)
                .designFont(.title)
                .multilineTextAlignment(.center)
            Text(payload.detail)
                .designFont(.body)
                .foregroundColor(Color(theme.colors.secondaryText))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var summary: some View {
        VStack(spacing: DesignKitMetrics.Spacing.regular.sizeInArtwork) {
            Rectangle()
                .fill(Color(theme.colors.divider))
                .frame(height: DesignKitMetrics.Stroke.divider.strokeInArtwork)
            ForEach(payload.summary.indices, id: \.self) { index in
                HStack(alignment: .firstTextBaseline, spacing: DesignKitMetrics.Spacing.regular.sizeInArtwork) {
                    Text(payload.summary[index].label)
                        .foregroundColor(Color(theme.colors.secondaryText))
                    Spacer(minLength: DesignKitMetrics.Spacing.compact.sizeInArtwork)
                    Text(payload.summary[index].value)
                        .designFont(.headline)
                        .multilineTextAlignment(.trailing)
                }
                .designFont(.subheadline)
            }
        }
    }

    @ViewBuilder
    private var footnote: some View {
        if let footnote = payload.footnote {
            Text(footnote)
                .designFont(.footnote)
                .foregroundColor(Color(theme.colors.secondaryText))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
