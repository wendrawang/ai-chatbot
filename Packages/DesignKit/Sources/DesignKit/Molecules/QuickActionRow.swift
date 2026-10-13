import SwiftUI

public struct QuickActionRow: View {
    @Environment(\.theme)
    private var theme
    private let action: QuickActionData
    private let onSelect: (QuickActionData) -> Void

    public init(action: QuickActionData, onSelect: @escaping (QuickActionData) -> Void) {
        self.action = action
        self.onSelect = onSelect
    }

    public var body: some View {
        Button {
            onSelect(action)
        } label: {
            HStack(spacing: FigmaSize.spacing16.sizeInArtwork) {
                leadingIcon
                VStack(alignment: .leading, spacing: FigmaSize.spacing4.sizeInArtwork) {
                    Text(action.title)
                        .designFont(.button)
                        .foregroundColor(Color(theme.colors.primaryText))
                    Text(action.subtitle)
                        .designFont(.caption)
                        .foregroundColor(Color(theme.colors.secondaryText))
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: DesignKitMetrics.Conversation.actionChevron.sizeInArtwork,
                        height: DesignKitMetrics.Conversation.actionChevron.sizeInArtwork
                    )
                    .foregroundColor(Color(theme.colors.accent))
                    .accessibilityHidden(true)
            }
            .padding(FigmaSize.spacing16.sizeInArtwork)
            .frame(minHeight: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork)
            .background(Color(theme.colors.surface))
            .cornerRadius(DesignKitMetrics.Conversation.quickActionRadius.sizeInArtwork)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("quick.action.\(action.identifier)")
    }

    private var leadingIcon: some View {
        Image(systemName: action.symbolName)
            .resizable()
            .scaledToFit()
            .frame(width: DesignKitMetrics.Size.icon.sizeInArtwork, height: DesignKitMetrics.Size.icon.sizeInArtwork)
            .foregroundColor(Color(theme.colors.accent))
            .accessibilityHidden(true)
    }
}
