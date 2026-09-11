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
public struct TanyaAITextBubble: View {
    let text: String
    let isUser: Bool
    @Environment(\.tanyaAITheme) private var theme

    /// Matches the outlined rows used by suggestions and hand-off links, so
    /// the whole conversation shares one corner.
    public static let cornerRadius: CGFloat = 12

    public init(
        text: String,
        isUser: Bool
    ) {
        self.text = text
        self.isUser = isUser
    }

    public var body: some View {
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
