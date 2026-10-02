import SwiftUI

public struct ReceiptBubble: View {
    let payload: ReceiptPayload
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

    public init(payload: ReceiptPayload) {
        self.payload = payload
    }

    public var body: some View {
        VStack(spacing: artwork.size(DesignKitMetrics.Spacing.wide)) {
            successHeader
            summary
            footnote
        }
        .foregroundColor(Color(theme.colors.primaryText))
        .padding(artwork.size(DesignKitMetrics.Spacing.card))
        .background(Color(theme.colors.surface))
        .cornerRadius(artwork.size(DesignKitMetrics.Radius.card))
        .frame(maxWidth: artwork.size(DesignKitMetrics.Size.cardMaximumWidth), alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("receipt.success")
    }

    private var successHeader: some View {
        VStack(spacing: artwork.size(DesignKitMetrics.Spacing.medium)) {
            Image(systemName: "checkmark")
                .designFont(.title)
                .foregroundColor(Color(theme.colors.success))
                .frame(
                            width: artwork.size(DesignKitMetrics.Size.successIcon),
                            height: artwork.size(DesignKitMetrics.Size.successIcon)
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
        VStack(spacing: artwork.size(DesignKitMetrics.Spacing.regular)) {
            Rectangle()
                .fill(Color(theme.colors.divider))
                .frame(height: artwork.stroke(0.5))
            ForEach(payload.summary.indices, id: \.self) { index in
                HStack(alignment: .firstTextBaseline, spacing: artwork.size(DesignKitMetrics.Spacing.regular)) {
                    Text(payload.summary[index].label)
                        .foregroundColor(Color(theme.colors.secondaryText))
                    Spacer(minLength: artwork.size(DesignKitMetrics.Spacing.compact))
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
