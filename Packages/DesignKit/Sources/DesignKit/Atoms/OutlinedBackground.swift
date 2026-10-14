import SwiftUI

/// A neutral outlined surface used by selectable rows.
public struct OutlinedBackground: View {
    @Environment(\.theme)
    private var theme

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
