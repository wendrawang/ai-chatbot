import SwiftUI

/// Outgoing text uses an accent bubble; incoming text is an unboxed response.
public struct TextBubble: View {
    @Environment(\.copyCatalog)
    private var copy
    @Environment(\.theme)
    private var theme
    let text: String
    let isUser: Bool
    private let runs: [MarkupRun]
    private let onLink: ((URL) -> Void)?
    private let maximumWidth: CGFloat?
    private let fontRole: DesignFontRole
    private let foregroundColor: Color?

    public init(
        text: String,
        isUser: Bool,
        onLink: ((URL) -> Void)? = nil,
        maximumWidth: CGFloat? = nil,
        fontRole: DesignFontRole = .body,
        foregroundColor: Color? = nil
    ) {
        self.text = text
        self.isUser = isUser
        self.onLink = onLink
        self.maximumWidth = maximumWidth
        self.fontRole = fontRole
        self.foregroundColor = foregroundColor
        runs = MarkupParser.runs(from: text.isEmpty ? "…" : text)
    }

    public var body: some View {
        labelledBubble
            .frame(
                maxWidth: maximumWidth ?? (isUser ? DesignKitMetrics.Size.bubbleMaximumWidth.sizeInArtwork : .infinity),
                alignment: isUser ? .trailing : .leading
            )
    }

    private var bubble: some View {
        RichText(
            runs: runs,
            font: Font(theme.fonts.font(for: fontRole)),
            color: textColor,
            linkColor: isUser ? textColor : Color(theme.colors.accent),
            onLink: onLink
        )
        .lineSpacing(theme.fonts.lineSpacing(for: fontRole))
        .padding(.horizontal, isUser ? FigmaSize.spacing16.sizeInArtwork : 0)
        .padding(.vertical, isUser ? DesignKitMetrics.Spacing.regular.sizeInArtwork : 0)
        .background(background)
    }

    @ViewBuilder
    private var labelledBubble: some View {
        if text.isEmpty {
            bubble.accessibilityLabel(copy.design("design.responding"))
        } else {
            // Native Text keeps the accessibility actions of attributed links.
            bubble
        }
    }

    @ViewBuilder
    private var background: some View {
        if isUser {
            OutgoingBubbleShape(radius: DesignKitMetrics.Radius.bubble.sizeInArtwork)
                .fill(Color(theme.colors.userBubble))
        }
    }

    private var textColor: Color {
        foregroundColor
            ?? Color(
                isUser
                    ? theme.colors.userBubbleText
                    : theme.colors.assistantBubbleText
            )
    }
}

/// The straight lower trailing corner identifies the outgoing side.
private struct OutgoingBubbleShape: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let corner = min(radius, min(rect.width, rect.height) / 2)
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + corner, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - corner, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + corner),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + corner, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - corner),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + corner))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + corner, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.closeSubpath()
        return path
    }
}
