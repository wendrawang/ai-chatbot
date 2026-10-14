import SwiftUI

/// A reusable control for returning to the newest content in a scrolling view.
public struct ScrollToLatestButton: View {
    @Environment(\.theme)
    private var theme
    private let label: String
    private let onTap: () -> Void

    public init(label: String, onTap: @escaping () -> Void) {
        self.label = label
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            // TODO: Replace the symbol with the approved down-arrow asset from Figma if its artwork differs.
            Image(systemName: "arrow.down")
                .resizable()
                .scaledToFit()
                .frame(
                    width: DesignKitMetrics.Size.icon.sizeInArtwork,
                    height: DesignKitMetrics.Size.icon.sizeInArtwork
                )
                .foregroundColor(Color(theme.colors.accent))
                .frame(
                    width: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork,
                    height: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork
                )
                .background(Color(theme.colors.surface))
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(
                        Color(theme.colors.divider), lineWidth: DesignKitMetrics.Stroke.hairline.strokeInArtwork
                    ))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label))
    }
}
