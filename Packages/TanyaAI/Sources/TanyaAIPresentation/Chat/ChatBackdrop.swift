import DesignKit
import SwiftUI

/// Artwork slot: replace the decorative wave with the approved exported asset when available.
struct ChatBackdrop: View {
    @Environment(\.theme)
    private var theme

    var body: some View {
        Color(theme.colors.background)
            .overlay(
                ConversationWave()
                    .fill(
                        LinearGradient(
                            colors: [Color(theme.colors.accent).opacity(ChatLayoutMetrics.backdropOpacity), .clear],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            )
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}

private struct ConversationWave: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height * 0.12))
        path.addCurve(
            to: CGPoint(x: rect.width, y: rect.height * 0.18),
            control1: CGPoint(x: rect.width * 0.3, y: rect.height * 0.02),
            control2: CGPoint(x: rect.width * 0.65, y: rect.height * 0.27)
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}
