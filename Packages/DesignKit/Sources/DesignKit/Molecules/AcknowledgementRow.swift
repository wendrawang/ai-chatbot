import SwiftUI

/// A document acknowledgement. Opening and approving a document belong to the caller.
public struct AcknowledgementRow: View {
    @Environment(\.theme)
    private var theme
    private let title: String
    private let isAccepted: Bool
    private let isEnabled: Bool
    private let action: () -> Void

    public init(title: String, isAccepted: Bool, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isAccepted = isAccepted
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: FigmaSize.spacing16.sizeInArtwork) {
                Text(title)
                    .designFont(.subheadline)
                    .foregroundColor(Color(theme.colors.primaryText))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: isAccepted ? "checkmark.circle.fill" : "circle")
                    .designFont(.headline)
                    .foregroundColor(Color(isAccepted ? theme.colors.success : theme.colors.primaryText))
                    .accessibilityHidden(true)
            }
            .padding(FigmaSize.spacing16.sizeInArtwork)
            .frame(minHeight: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork)
            .background(
                RoundedRectangle(cornerRadius: DesignKitMetrics.Conversation.summaryRadius.sizeInArtwork)
                    .strokeBorder(
                        Color(isAccepted ? theme.colors.success : theme.colors.divider),
                        lineWidth: DesignKitMetrics.Stroke.hairline.strokeInArtwork
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isEnabled == false)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isAccepted ? .isSelected : [])
    }
}
