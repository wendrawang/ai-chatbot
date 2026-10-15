import SwiftUI

/// A neutral outlined surface used by selectable rows.
public struct OutlinedBackground: View {
    @Environment(\.theme)
    private var theme

    public init() {}

    public var body: some View {
        RoundedRectangle(cornerRadius: DesignKitMetrics.Radius.bubble.scaledToArtwork)
            .fill(Color(theme.colors.assistantBubble))
            .overlay(
                RoundedRectangle(cornerRadius: DesignKitMetrics.Radius.bubble.scaledToArtwork)
                    .stroke(Color(theme.colors.divider), lineWidth: DesignKitMetrics.Stroke.hairline.strokeInArtwork)
            )
    }
}
