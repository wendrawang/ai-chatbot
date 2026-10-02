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
    private let runs: [MarkupRun]
    @Environment(\.copyCatalog) private var copy
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

    public init(
        text: String,
        isUser: Bool
    ) {
        self.text = text
        self.isUser = isUser
        runs = MarkupParser.runs(from: text.isEmpty ? "…" : text)
    }

    public var body: some View {
        bubble
            .frame(
                maxWidth: artwork.size(DesignKitMetrics.Size.bubbleMaximumWidth),
                alignment: isUser ? .trailing : .leading
            )
    }

    private var bubble: some View {
        RichText(
            runs: runs,
            font: Font(theme.fonts.body),
            color: textColor
        )
        .lineSpacing(theme.fonts.lineSpacing(for: .body))
        .padding(.horizontal, artwork.size(DesignKitMetrics.Spacing.wide))
        .padding(.vertical, artwork.size(DesignKitMetrics.Spacing.regular))
        .background(background)
        .accessibility(
            label: Text(accessibilityText)
        )
    }

    private var accessibilityText: String {
        text.isEmpty ? copy.design("design.responding") : runs.map(\.text).joined()
    }

    @ViewBuilder
    private var background: some View {
        if isUser {
            RoundedRectangle(cornerRadius: artwork.size(DesignKitMetrics.Radius.bubble))
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
