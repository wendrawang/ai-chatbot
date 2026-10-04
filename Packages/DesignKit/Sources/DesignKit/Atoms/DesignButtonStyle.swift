import SwiftUI

/// Shared feedback and minimum hit area, without owning actions or feature state.
public struct DesignButtonStyle: ButtonStyle {
    public enum Emphasis {
        case primary
        case secondary
    }

    private let emphasis: Emphasis
    @Environment(\.theme) private var theme

    @Environment(\.isEnabled) private var isEnabled

    public init(_ emphasis: Emphasis = .primary) {
        self.emphasis = emphasis
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .designFont(.button)
            .padding(.horizontal, DesignKitMetrics.Spacing.compact.sizeInArtwork)
            .padding(.vertical, DesignKitMetrics.Spacing.tight.sizeInArtwork)
            .frame(
                minWidth: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork,
                minHeight: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork
            )
            .foregroundColor(Color(emphasis == .primary ? theme.colors.userBubbleText : theme.colors.primaryText))
            .background(Color(emphasis == .primary ? theme.colors.accent : theme.colors.background))
            .cornerRadius(DesignKitMetrics.Radius.bubble.sizeInArtwork)
            .opacity(isEnabled
                ? (configuration.isPressed ? DesignKitMetrics.Opacity.pressed : 1)
                : DesignKitMetrics.Opacity.disabled)
            .contentShape(Rectangle())
    }
}
