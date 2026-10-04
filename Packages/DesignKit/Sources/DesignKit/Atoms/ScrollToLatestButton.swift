import SwiftUI

/// A reusable control for returning to the newest content in a scrolling view.
public struct ScrollToLatestButton: View {
    private let label: String
    private let onTap: () -> Void
    @Environment(\.theme) private var theme

    public init(label: String, onTap: @escaping () -> Void) {
        self.label = label
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            Image(systemName: "arrow.down")
                .designFont(.button)
                .foregroundColor(Color(theme.colors.accent))
                .frame(
                    width: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork,
                    height: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork
                )
                .background(Color(theme.colors.surface))
                .clipShape(Circle())
                .overlay(Circle().stroke(
                    Color(theme.colors.divider), lineWidth: DesignKitMetrics.Stroke.hairline.strokeInArtwork
                ))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label))
    }
}
