import SwiftUI

/// One message bubble.
///
/// The customer's own words sit in an accent bubble on the right; a reply sits
/// in a surface bubble on the left, under the Tanya AI attribution, and may
/// carry inline emphasis so a labelled list reads as one answer instead of
/// several bubbles.
struct TanyaAITextBubble: View {
    let text: String
    let isUser: Bool
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        if isUser {
            bubble
                .frame(maxWidth: 310, alignment: .trailing)
        } else {
            VStack(alignment: .leading, spacing: 6) {
                TanyaAIAssistantHeader()
                bubble
            }
            .frame(maxWidth: 310, alignment: .leading)
        }
    }

    private var bubble: some View {
        TanyaAIRichText(
            text: text.isEmpty ? "…" : text,
            font: theme.fonts.body,
            color: textColor
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(backgroundColor)
        .clipShape(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .accessibility(
            label: Text(text.isEmpty ? "Tanya AI is responding" : text)
        )
    }

    private var backgroundColor: Color {
        isUser ? theme.colors.userBubble : theme.colors.assistantBubble
    }

    private var textColor: Color {
        isUser ? theme.colors.userBubbleText : theme.colors.assistantBubbleText
    }
}
