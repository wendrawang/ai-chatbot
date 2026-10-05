import SwiftUI

/// A tappable option with a circular affordance and a wrapping label.
public struct OptionRow: View {
    let option: SelectionOption
    let onSelect: (SelectionOption) -> Void
    @Environment(\.theme) private var theme

    public init(
        option: SelectionOption,
        onSelect: @escaping (SelectionOption) -> Void
    ) {
        self.option = option
        self.onSelect = onSelect
    }

    public var body: some View {
        Button {
            onSelect(option)
        } label: {
            content
        }
        .buttonStyle(.plain)
        .accessibility(
            label: Text(option.title)
        )
        .accessibilityIdentifier("option.\(option.identifier)")
    }

    private var content: some View {
        HStack(spacing: DesignKitMetrics.Spacing.regular.sizeInArtwork) {
            Circle()
                .stroke(
                    Color(theme.colors.primaryText),
                    lineWidth: DesignKitMetrics.Stroke.indicator.strokeInArtwork
                )
                .frame(
                    width: DesignKitMetrics.Size.indicator.sizeInArtwork,
                    height: DesignKitMetrics.Size.indicator.sizeInArtwork
                )
            Text(option.title)
                .designFont(.body)
                .foregroundColor(Color(theme.colors.primaryText))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(
            maxWidth: .infinity,
            minHeight: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork,
            alignment: .leading
        )
        .padding(.horizontal, FigmaSize.spacing16.sizeInArtwork)
        .padding(.vertical, FigmaSize.spacing8.sizeInArtwork)
        .background(OutlinedBackground())
    }
}
