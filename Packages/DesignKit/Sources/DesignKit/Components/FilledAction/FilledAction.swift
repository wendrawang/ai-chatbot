import SwiftUI

/// A prominent pill action with caller-supplied artwork and optional tint.
public struct FilledAction<Icon: View>: View {
    @Environment(\.theme)
    private var theme
    private let title: String
    private let tint: Color?
    private let isEnabled: Bool
    private let onTap: () -> Void
    private let icon: Icon

    public init(
        title: String, tint: Color? = nil, isEnabled: Bool = true,
        onTap: @escaping () -> Void, @ViewBuilder icon: () -> Icon
    ) {
        self.title = title
        self.tint = tint
        self.isEnabled = isEnabled
        self.onTap = onTap
        self.icon = icon()
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: FigmaSize.spacing8.scaledToArtwork) {
                icon
                    .frame(
                        width: DesignKitMetrics.Size.icon.scaledToArtwork,
                        height: DesignKitMetrics.Size.icon.scaledToArtwork
                    )
                    .accessibilityHidden(true)
                Text(title)
                    .designFont(.button)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundColor(Color(theme.colors.userBubbleText))
            .padding(.horizontal, FigmaSize.spacing16.scaledToArtwork)
            .padding(.vertical, FigmaSize.spacing8.scaledToArtwork)
            .frame(minHeight: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork)
            .background(RoundedRectangle(cornerRadius: DesignKitMetrics.Radius.action.scaledToArtwork).fill(background))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(title)
    }

    private var background: LinearGradient {
        let color = tint ?? Color(theme.colors.accent)
        return LinearGradient(
            colors: [color.opacity(DesignKitMetrics.Opacity.gradientStart), color],
            startPoint: .leading, endPoint: .trailing
        )
    }
}
