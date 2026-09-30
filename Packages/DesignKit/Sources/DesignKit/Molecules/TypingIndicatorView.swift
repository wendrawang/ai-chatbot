import Foundation
import SwiftUI

/// The waiting state, shaped like the reply it will become.
///
/// Three dots inside an assistant bubble rather than a spinner on a row of
/// its own, so the conversation does not jump when the answer arrives.
///
/// The animation is scoped to `isAnimating`. The unscoped `animation(_:)`
/// would animate every change in this subtree - including the layout the row
/// gets when the table first places it - which reads as a stray slide.
public struct TypingIndicatorView: View {
    @Environment(\.theme) private var theme
    @State private var isAnimating = false

    private let dotCount = 3

    public init() {}

    public var body: some View {
        dots
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .ignore)
            .accessibility(label: Text("Assistant is responding"))
            .onAppear {
                // Starting the loop in the same pass the view appears leaves
                // the dots static: the animation modifier is not installed yet.
                DispatchQueue.main.async {
                    isAnimating = true
                }
            }
    }

    private var dots: some View {
        HStack(spacing: DesignKitMetrics.Spacing.snug) {
            ForEach(0..<dotCount, id: \.self) { index in
                Circle()
                    .fill(Color(theme.colors.secondaryText))
                    .frame(width: DesignKitMetrics.Size.dot, height: DesignKitMetrics.Size.dot)
                    .opacity(isAnimating ? 1 : 0.3)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .padding(.horizontal, DesignKitMetrics.Spacing.wide)
        .padding(.vertical, DesignKitMetrics.Spacing.roomy)
        .background(OutlinedBackground())
    }
}
