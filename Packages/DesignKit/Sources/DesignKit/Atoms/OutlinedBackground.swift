import SwiftUI

/// The outlined shape a reply, a suggestion and a hand-off link all sit in.
///
/// One place, so the three never drift apart: they appear next to each other
/// in the same conversation.
public struct OutlinedBackground: View {
    @Environment(\.theme) private var theme

    public init() {}

    public var body: some View {
        RoundedRectangle(cornerRadius: DesignKitMetrics.Radius.bubble.sizeInArtwork)
            .fill(Color(theme.colors.assistantBubble))
            .overlay(
                RoundedRectangle(cornerRadius: DesignKitMetrics.Radius.bubble.sizeInArtwork)
                    .stroke(Color(theme.colors.divider), lineWidth: DesignKitMetrics.Stroke.hairline.strokeInArtwork)
            )
    }
}
