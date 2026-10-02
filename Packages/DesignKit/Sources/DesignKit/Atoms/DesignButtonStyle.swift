import SwiftUI

/// Shared feedback and minimum hit area, without owning actions or feature state.
public struct DesignButtonStyle: ButtonStyle {
    public enum Emphasis {
        case primary
        case secondary
    }

    private let emphasis: Emphasis
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork
    @Environment(\.isEnabled) private var isEnabled

    public init(_ emphasis: Emphasis = .primary) {
        self.emphasis = emphasis
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .designFont(.button)
            .padding(.horizontal, artwork.size(DesignKitMetrics.Spacing.compact))
            .padding(.vertical, artwork.size(DesignKitMetrics.Spacing.tight))
            .frame(minWidth: artwork.tapTarget(), minHeight: artwork.tapTarget())
            .foregroundColor(Color(emphasis == .primary ? theme.colors.userBubbleText : theme.colors.primaryText))
            .background(Color(emphasis == .primary ? theme.colors.accent : theme.colors.background))
            .cornerRadius(artwork.size(DesignKitMetrics.Radius.bubble))
            .opacity(isEnabled
                ? (configuration.isPressed ? DesignKitMetrics.Opacity.pressed : 1)
                : DesignKitMetrics.Opacity.disabled)
            .contentShape(Rectangle())
    }
}
