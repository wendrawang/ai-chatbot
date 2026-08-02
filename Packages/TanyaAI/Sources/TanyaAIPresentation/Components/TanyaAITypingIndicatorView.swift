import SwiftUI

struct TanyaAITypingIndicatorView: View {
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        HStack(spacing: 8) {
            TanyaAIActivityIndicator(color: theme.colors.accent)
                .frame(width: 20, height: 20)
            Text("Tanya AI is responding")
                .font(Font(theme.fonts.footnote))
                .foregroundColor(Color(theme.colors.secondaryText))
            Spacer()
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}

private struct TanyaAIActivityIndicator: UIViewRepresentable {
    let color: UIColor

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = color
        indicator.startAnimating()
        return indicator
    }

    func updateUIView(
        _ indicator: UIActivityIndicatorView,
        context: Context
    ) {
        indicator.color = color
        if !indicator.isAnimating {
            indicator.startAnimating()
        }
    }
}
