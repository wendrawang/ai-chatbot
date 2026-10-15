import SwiftUI

/// A tappable option with a circular affordance and a wrapping label.
public struct OptionRow: View {
    @Environment(\.theme)
    private var theme
    let option: SelectionOption
    let isSelected: Bool
    let isEnabled: Bool
    let onSelect: (SelectionOption) -> Void

    public init(
        option: SelectionOption,
        isSelected: Bool = false,
        isEnabled: Bool = true,
        onSelect: @escaping (SelectionOption) -> Void
    ) {
        self.option = option
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.onSelect = onSelect
    }

    public var body: some View {
        Button {
            onSelect(option)
        } label: {
            content
        }
        .buttonStyle(OptionRowButtonStyle())
        .disabled(isEnabled == false)
        .accessibility(
            label: Text(option.title)
        )
        .accessibilityIdentifier("option.\(option.identifier)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var content: some View {
        HStack(spacing: DesignKitMetrics.Spacing.regular.sizeInArtwork) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color(indicatorColor))
                .frame(
                    width: DesignKitMetrics.Size.indicator.sizeInArtwork,
                    height: DesignKitMetrics.Size.indicator.sizeInArtwork
                )
                .accessibilityHidden(true)
            Text(option.title)
                .designFont(.body)
                .foregroundColor(Color(isEnabled || isSelected ? theme.colors.primaryText : theme.colors.secondaryText))
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

    private var indicatorColor: UIColor {
        if isSelected { return theme.colors.success }
        return isEnabled ? theme.colors.primaryText : theme.colors.secondaryText
    }
}

/// Selection history supplies its own colors. Do not dim the selected green
/// indicator again merely because the button no longer accepts input.
private struct OptionRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
