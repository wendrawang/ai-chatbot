import SwiftUI

/// An underlined action. URL validation and routing belong to the caller.
public struct LinkAction: View {
    @Environment(\.theme)
    private var theme
    private let title: String
    private let isEnabled: Bool
    private let onTap: () -> Void

    public init(title: String, isEnabled: Bool = true, onTap: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            Text(title)
                .underline()
                .designFont(.footnote)
                .foregroundColor(Color(theme.colors.accent))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, FigmaSize.spacing16.scaledToArtwork)
                .padding(.vertical, FigmaSize.spacing8.scaledToArtwork)
                .background(
                    RoundedRectangle(cornerRadius: DesignKitMetrics.Radius.action.scaledToArtwork)
                        .strokeBorder(
                            Color(theme.colors.divider),
                            lineWidth: DesignKitMetrics.Stroke.hairline.strokeInArtwork)
                )
                .frame(
                    minWidth: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork,
                    minHeight: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork, alignment: .leading
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(title)
    }
}
