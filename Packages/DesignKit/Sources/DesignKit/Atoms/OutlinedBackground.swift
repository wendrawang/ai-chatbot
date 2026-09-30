import SwiftUI

/// The outlined shape a reply, a suggestion and a hand-off link all sit in.
///
/// One place, so the three never drift apart: they appear next to each other
/// in the same conversation.
struct OutlinedBackground: View {
    @Environment(\.theme) private var theme

    var body: some View {
        RoundedRectangle(cornerRadius: DesignKitMetrics.Radius.bubble)
            .fill(Color(theme.colors.assistantBubble))
            .overlay(
                RoundedRectangle(cornerRadius: DesignKitMetrics.Radius.bubble)
                    .stroke(Color(theme.colors.divider), lineWidth: DesignKitMetrics.Stroke.hairline)
            )
    }
}
