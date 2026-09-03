import SwiftUI

/// The waiting state, shaped like the reply it will become.
///
/// Three dots inside an assistant bubble rather than a spinner on a row of
/// its own, so the conversation does not jump when the answer arrives.
struct TanyaAITypingIndicatorView: View {
    @Environment(\.tanyaAITheme) private var theme
    @State private var isAnimating = false

    private let dotCount = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TanyaAIAssistantHeader()
            dots
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("Tanya AI is responding"))
        .onAppear {
            isAnimating = true
        }
    }

    private var dots: some View {
        HStack(spacing: 6) {
            ForEach(0..<dotCount, id: \.self) { index in
                Circle()
                    .fill(Color(theme.colors.secondaryText))
                    .frame(width: 8, height: 8)
                    .opacity(isAnimating ? 1 : 0.3)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2)
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(theme.colors.assistantBubble))
        .cornerRadius(18)
    }
}
