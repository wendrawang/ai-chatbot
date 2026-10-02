import SwiftUI

/// Outgoing text uses an accent bubble; incoming text is an unboxed response.
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
        .padding(.horizontal, isUser ? artwork.size(DesignKitMetrics.Spacing.wide) : 0)
        .padding(.vertical, isUser ? artwork.size(DesignKitMetrics.Spacing.regular) : 0)
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
