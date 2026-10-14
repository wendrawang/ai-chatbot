import SwiftUI

/// A vertical list of options; each tap reports the selected value.
public struct OptionList: View {
    @Environment(\.theme)
    private var theme
    let title: String?
    let options: [SelectionOption]
    let selectedIdentifier: String?
    let isEnabled: Bool
    let maximumWidth: CGFloat?
    let onSelect: (SelectionOption) -> Void

    public init(
        title: String?,
        options: [SelectionOption],
        selectedIdentifier: String? = nil,
        isEnabled: Bool = true,
        maximumWidth: CGFloat? = DesignKitMetrics.Size.bubbleMaximumWidth.sizeInArtwork,
        onSelect: @escaping (SelectionOption) -> Void
    ) {
        self.title = title
        self.options = options
        self.selectedIdentifier = selectedIdentifier
        self.isEnabled = isEnabled
        self.maximumWidth = maximumWidth
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(
            alignment: .leading,
            spacing: DesignKitMetrics.Spacing.regular.sizeInArtwork
        ) {
            heading
            rows
        }
        .frame(
            maxWidth: maximumWidth,
            alignment: .leading
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("options.list")
    }

    @ViewBuilder
    private var heading: some View {
        if let title = title, title.isEmpty == false {
            Text(title)
                .designFont(.headline)
                .foregroundColor(Color(theme.colors.primaryText))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var rows: some View {
        VStack(
            alignment: .leading,
            spacing: FigmaSize.spacing8.sizeInArtwork
        ) {
            ForEach(options, id: \.identifier) { option in
                OptionRow(
                    option: option,
                    isSelected: option.identifier == selectedIdentifier,
                    isEnabled: isEnabled && selectedIdentifier == nil,
                    onSelect: onSelect
                )
            }
        }
    }
}
