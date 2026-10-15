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
            HStack(spacing: FigmaSize.spacing16.scaledToArtwork) {
                leadingIcon
                VStack(alignment: .leading, spacing: FigmaSize.spacing4.scaledToArtwork) {
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
                        width: DesignKitMetrics.Size.actionChevron.scaledToArtwork,
                        height: DesignKitMetrics.Size.actionChevron.scaledToArtwork
                    )
                    .foregroundColor(Color(theme.colors.accent))
                    .accessibilityHidden(true)
            }
            .padding(FigmaSize.spacing16.scaledToArtwork)
            .frame(minHeight: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork)
            .background(Color(theme.colors.surface))
            .cornerRadius(DesignKitMetrics.Radius.quickAction.scaledToArtwork)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("quick.action.\(action.identifier)")
    }

    private var leadingIcon: some View {
        // TODO: Replace the placeholder symbol with the approved recommendation artwork from Figma.
        Image(systemName: action.symbolName)
            .resizable()
            .scaledToFit()
            .frame(
                width: DesignKitMetrics.Size.icon.scaledToArtwork, height: DesignKitMetrics.Size.icon.scaledToArtwork
            )
            .foregroundColor(Color(theme.colors.accent))
            .accessibilityHidden(true)
    }
}
