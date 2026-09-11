import SwiftUI

/// The outlined shape a reply, a suggestion and a hand-off link all sit in.
///
/// One place, so the three never drift apart: they appear next to each other
/// in the same conversation.
struct TanyaAIOutlinedBackground: View {
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        RoundedRectangle(cornerRadius: TanyaAITextBubble.cornerRadius)
            .fill(Color(theme.colors.assistantBubble))
            .overlay(
                RoundedRectangle(cornerRadius: TanyaAITextBubble.cornerRadius)
                    .stroke(Color(theme.colors.divider), lineWidth: 1)
            )
    }
}
