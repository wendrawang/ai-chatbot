import SwiftUI

/// One message bubble.
///
/// The customer's own words sit in an accent bubble on the right; a reply sits
/// in an outlined bubble on the left, and may carry inline styling so a
/// labelled list reads as one answer instead of several bubbles.
///
/// The reply is outlined rather than filled, and carries no "Tanya AI"
/// attribution above it. Two filled colours facing each other made every
/// exchange look like two shouting sides; the outline lets the customer's own
/// turns be the only thing with weight.
struct TanyaAITextBubble: View {
    let text: String
    let isUser: Bool
    @Environment(\.tanyaAITheme) private var theme

    /// Matches the outlined rows used by suggestions and hand-off links, so
    /// the whole conversation shares one corner.
    static let cornerRadius: CGFloat = 12

    var body: some View {
        bubble
            .frame(
                maxWidth: 310,
                alignment: isUser ? .trailing : .leading
            )
    }

    private var bubble: some View {
        TanyaAIRichText(
            text: text.isEmpty ? "…" : text,
            font: Font(theme.fonts.body),
            color: textColor
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(background)
        .accessibility(
            label: Text(text.isEmpty ? "Tanya AI is responding" : text)
        )
    }

    @ViewBuilder
    private var background: some View {
        if isUser {
            RoundedRectangle(cornerRadius: Self.cornerRadius)
                .fill(Color(theme.colors.userBubble))
        } else {
            TanyaAIOutlinedBackground()
        }
    }

    private var textColor: Color {
        Color(
            isUser
                ? theme.colors.userBubbleText
                : theme.colors.assistantBubbleText
        )
    }
}

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
