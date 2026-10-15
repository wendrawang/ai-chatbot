import SwiftUI

/// An outlined action; the caller owns whether it sends text or navigates.
public struct ActionPill: View {
    @Environment(\.theme)
    private var theme
    private let title: String
    private let symbolName: String?
    private let isEnabled: Bool
    private let action: () -> Void

    public init(title: String, symbolName: String? = nil, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.symbolName = symbolName
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: FigmaSize.spacing8.scaledToArtwork) {
                if let symbolName = symbolName {
                    Image(systemName: symbolName)
                        .foregroundColor(Color(theme.colors.accent))
                        .designFont(.footnote)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .designFont(.footnote)
                    .foregroundColor(Color(theme.colors.primaryText))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, FigmaSize.spacing16.scaledToArtwork)
            .padding(.vertical, FigmaSize.spacing8.scaledToArtwork)
            .background(
                RoundedRectangle(cornerRadius: DesignKitMetrics.Radius.action.scaledToArtwork).strokeBorder(
                    Color(theme.colors.divider), lineWidth: DesignKitMetrics.Stroke.hairline.strokeInArtwork
                )
            )
            .frame(
                minWidth: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork,
                minHeight: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isEnabled == false)
        .accessibilityLabel(title)
    }
}
