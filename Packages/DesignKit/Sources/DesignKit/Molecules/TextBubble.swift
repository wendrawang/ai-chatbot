import SwiftUI

/// One message bubble.
///
/// The customer's own words sit in an accent bubble on the right; a reply sits
/// in an outlined bubble on the left, and may carry inline styling so a
/// labelled list reads as one answer instead of several bubbles.
///
/// The reply is outlined rather than filled, and carries no attribution
/// above it. Two filled colours facing each other made every
/// exchange look like two shouting sides; the outline lets the customer's own
/// turns be the only thing with weight.
public struct TextBubble: View {
    let text: String
    let isUser: Bool
    @Environment(\.theme) private var theme

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
                maxWidth: DesignKitMetrics.Size.bubbleMaximumWidth,
                alignment: isUser ? .trailing : .leading
            )
    }

    private var bubble: some View {
        RichText(
            text: text.isEmpty ? "…" : text,
            font: Font(theme.fonts.body),
            color: textColor
        )
        .padding(.horizontal, DesignKitMetrics.Spacing.wide)
        .padding(.vertical, DesignKitMetrics.Spacing.regular)
        .background(background)
        .accessibility(
            label: Text(text.isEmpty ? "Assistant is responding" : text)
        )
    }

    @ViewBuilder
    private var background: some View {
        if isUser {
            RoundedRectangle(cornerRadius: DesignKitMetrics.Radius.bubble)
                .fill(Color(theme.colors.userBubble))
        } else {
            OutlinedBackground()
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
