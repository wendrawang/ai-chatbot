import SwiftUI

/// A vertical list of options; each tap reports the selected value.
public struct OptionList: View {
    let title: String?
    let options: [SelectionOption]
    let onSelect: (SelectionOption) -> Void
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

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
            spacing: artwork.size(DesignKitMetrics.Spacing.regular)
        ) {
            heading
            rows
        }
        .padding(artwork.size(DesignKitMetrics.Spacing.wide))
        .background(OutlinedBackground())
        .frame(
            maxWidth: artwork.size(DesignKitMetrics.Size.bubbleMaximumWidth),
            alignment: .leading
        )
        // Without the second frame the box is centred in the row and the
        // prompts sit indented from every bubble above them.
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
            spacing: artwork.size(DesignKitMetrics.Spacing.compact)
        ) {
            ForEach(options, id: \.identifier) { option in
                OptionRow(option: option, onSelect: onSelect)
            }
        }
    }
}
