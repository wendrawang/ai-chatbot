import SwiftUI

struct TanyaAITextBubble: View {
    let text: String
    let isUser: Bool
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        Text(text.isEmpty ? "…" : text)
            .font(Font(theme.fonts.body))
            .foregroundColor(textColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(backgroundColor)
            .cornerRadius(16)
            .frame(maxWidth: 310, alignment: isUser ? .trailing : .leading)
            .accessibility(
                label: Text(text.isEmpty ? "Tanya AI is responding" : text)
            )
    }

    private var backgroundColor: Color {
        Color(isUser ? theme.colors.userBubble : theme.colors.assistantBubble)
    }

    private var textColor: Color {
        Color(
            isUser ? theme.colors.userBubbleText : theme.colors.assistantBubbleText
        )
    }
}
