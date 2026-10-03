import SwiftUI

/// The outlined shape a reply, a suggestion and a hand-off link all sit in.
///
/// One place, so the three never drift apart: they appear next to each other
/// in the same conversation.
public struct OutlinedBackground: View {
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

    public init() {}

    public var body: some View {
        RoundedRectangle(cornerRadius: artwork.size(DesignKitMetrics.Radius.bubble))
            .fill(Color(theme.colors.assistantBubble))
            .overlay(
                RoundedRectangle(cornerRadius: artwork.size(DesignKitMetrics.Radius.bubble))
                    .stroke(Color(theme.colors.divider), lineWidth: artwork.stroke(DesignKitMetrics.Stroke.hairline))
            )
    }
}
