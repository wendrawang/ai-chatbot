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

    private var cornerRadius: CGFloat { DesignKitMetrics.Radius.bubble.sizeInArtwork }

    public init(payload: ImagePayload) {
        self.payload = payload
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            picture
            if let title = payload.title, !title.isEmpty {
                Text(title)
                    .designFont(.headline)
                    .foregroundColor(Color(theme.colors.primaryText))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, FigmaSize.spacing16.sizeInArtwork)
                    .padding(.top, DesignKitMetrics.Spacing.roomy.sizeInArtwork)
            }
            caption
        }
        .background(Color(theme.colors.assistantBubble))
        // Clipped before the outline is drawn, so the corners round the
        // artwork while the stroke keeps its full width.
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color(theme.colors.divider), lineWidth: DesignKitMetrics.Stroke.hairline.strokeInArtwork)
        )
        .frame(maxWidth: DesignKitMetrics.Size.bubbleMaximumWidth.sizeInArtwork, alignment: .leading)
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

    /// Hidden when empty, padding and all. An image that needs no words
    /// should not carry a blank strip under it.
    @ViewBuilder
    private var caption: some View {
        if payload.caption.isEmpty == false {
            captionText
        }
    }

    private var captionText: some View {
        Text(payload.caption)
            .designFont(payload.title == nil ? .headline : .body)
            .foregroundColor(Color(theme.colors.primaryText))
            .lineSpacing(DesignKitMetrics.Text.captionLineSpacing.sizeInArtwork)
            // Without this a long caption is truncated to one line instead of
            // wrapping: the row has no height to give it yet.
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, FigmaSize.spacing16.sizeInArtwork)
            .padding(.vertical, DesignKitMetrics.Spacing.roomy.sizeInArtwork)
    }
}
