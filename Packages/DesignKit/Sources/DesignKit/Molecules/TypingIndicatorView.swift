import Foundation
import SwiftUI

/// Unboxed activity dots aligned with incoming text.
///
/// The animation is scoped to `isAnimating`. The unscoped `animation(_:)`
/// would animate every change in this subtree - including the layout the row
/// gets when the table first places it - which reads as a stray slide.
public struct TypingIndicatorView: View {
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork
    @Environment(\.accessibilityReduceMotion) private var isReduceMotion
    @State private var isAnimating = false

    private let dotCount = DesignKitMetrics.Motion.dotCount

    private let label: String

    public init(label: String) {
        self.label = label
    }

    public var body: some View {
        dots
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .ignore)
            .accessibility(label: Text(label))
            .task(id: isReduceMotion) {
                isAnimating = false
                guard !isReduceMotion else { return }
                await Task.yield()
                guard !Task.isCancelled else { return }
                isAnimating = true
            }
            .onDisappear { isAnimating = false }
    }

    private var dots: some View {
        HStack(spacing: artwork.size(DesignKitMetrics.Spacing.snug)) {
            ForEach(0..<dotCount, id: \.self) { index in
                Circle()
                    .fill(Color(theme.colors.secondaryText))
                    .frame(
                        width: artwork.size(DesignKitMetrics.Size.dot),
                        height: artwork.size(DesignKitMetrics.Size.dot)
                    )
                    .opacity(isAnimating ? 1 : DesignKitMetrics.Opacity.restingDot)
                    .animation(
                        isReduceMotion ? nil : Animation.easeInOut(duration: DesignKitMetrics.Motion.dotDuration)
                            .repeatForever()
                            .delay(Double(index) * DesignKitMetrics.Motion.dotDelay),
                        value: isAnimating
                    )
            }
        }
        .padding(.vertical, artwork.size(DesignKitMetrics.Spacing.roomy))
    }
}
