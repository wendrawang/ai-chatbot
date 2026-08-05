import SwiftUI

struct TanyaAITypingIndicatorView: View {
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
                .tint(theme.colors.accent)
                .frame(width: 20, height: 20)
            Text("Tanya AI is responding")
                .font(theme.fonts.footnote)
                .foregroundColor(theme.colors.secondaryText)
            Spacer()
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}
