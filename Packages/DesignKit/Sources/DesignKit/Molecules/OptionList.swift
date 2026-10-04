import SwiftUI

/// A vertical list of options; each tap reports the selected value.
public struct OptionList: View {
    let title: String?
    let options: [SelectionOption]
    let onSelect: (SelectionOption) -> Void
    @Environment(\.theme) private var theme

    public init(
        title: String?,
        options: [SelectionOption],
        onSelect: @escaping (SelectionOption) -> Void
    ) {
        self.title = title
        self.options = options
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
            maxWidth: DesignKitMetrics.Size.bubbleMaximumWidth.sizeInArtwork,
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
            spacing: DesignKitMetrics.Spacing.compact.sizeInArtwork
        ) {
            ForEach(options, id: \.identifier) { option in
                OptionRow(option: option, onSelect: onSelect)
            }
        }
    }
}
