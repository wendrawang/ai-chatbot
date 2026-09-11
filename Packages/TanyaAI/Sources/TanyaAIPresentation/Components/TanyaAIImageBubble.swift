import SwiftUI
import TanyaAIDomain

/// A picture with a line of copy under it - a promo, mostly.
///
/// No bubble chrome: the picture is the frame. Wrapping artwork in a tinted
/// box would fight it, and the design puts this flush against the
/// conversation background.
struct TanyaAIImageBubble: View {
    let payload: TanyaAIImagePayload
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            picture
            caption
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("image.card")
    }

    @ViewBuilder
    private var picture: some View {
        if let imageURL = payload.imageURL {
            TanyaAIRemoteImage(
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
            .lineSpacing(6)
            // Without this a long caption is truncated to one line instead of
            // wrapping: the row has no height to give it yet.
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
