import SwiftUI

/// Marks a reply as coming from Tanya AI.
///
/// Sits above the bubble rather than inside it, so the bubble keeps its full
/// width for content and consecutive replies stay visually attributed.
struct TanyaAIAssistantHeader: View {
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        HStack(spacing: 8) {
            avatar
            Text("TANYA AI")
                .font(theme.fonts.caption)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.secondaryText)
        }
        .accessibilityHidden(true)
    }

    private var avatar: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [
                        theme.colors.accent,
                        theme.colors.accent.opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 22, height: 22)
            .overlay(
                Image(systemName: "sparkles")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(theme.colors.userBubbleText)
            )
    }
}
