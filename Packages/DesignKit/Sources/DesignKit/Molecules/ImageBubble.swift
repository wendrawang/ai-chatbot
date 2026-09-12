import SwiftUI

/// A picture and the line of copy that goes with it - a promo, mostly - as
/// one bubble.
///
/// The picture is flush to the bubble's top edge rather than inset inside it:
/// the bubble's own corners round the artwork, so the two read as one card
/// instead of a photo sitting in a box. How the height divides between them is
/// the artwork's business - `aspectRatio` sets the picture, the caption takes
/// what it needs underneath.
public struct ImageBubble: View {
    let payload: ImagePayload
    @Environment(\.theme) private var theme

    private var cornerRadius: CGFloat { DesignKitMetrics.Radius.bubble }

    public init(payload: ImagePayload) {
        self.payload = payload
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            picture
            caption
        }
        .background(Color(theme.colors.assistantBubble))
        // Clipped before the outline is drawn, so the corners round the
        // artwork while the stroke keeps its full width.
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color(theme.colors.divider), lineWidth: DesignKitMetrics.Stroke.hairline)
        )
        .frame(maxWidth: DesignKitMetrics.Size.bubbleMaximumWidth, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("image.card")
    }

    @ViewBuilder
    private var picture: some View {
        if let imageURL = payload.imageURL {
            RemoteImage(
                url: imageURL,
                aspectRatio: payload.aspectRatio
            )
            .accessibility(hidden: payload.accessibilityText == nil)
            .accessibility(
                label: Text(payload.accessibilityText ?? "")
            )
        }
    }

    private var caption: some View {
        Text(payload.caption)
            .font(Font(theme.fonts.headline))
            .foregroundColor(Color(theme.colors.primaryText))
            .lineSpacing(DesignKitMetrics.Text.captionLineSpacing)
            // Without this a long caption is truncated to one line instead of
            // wrapping: the row has no height to give it yet.
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignKitMetrics.Spacing.wide)
            .padding(.vertical, DesignKitMetrics.Spacing.roomy)
    }
}
