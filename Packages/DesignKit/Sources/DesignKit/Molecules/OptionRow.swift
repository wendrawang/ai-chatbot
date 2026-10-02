import SwiftUI

/// A tappable option with a circular affordance and a wrapping label.
public struct OptionRow: View {
    let option: SelectionOption
    let onSelect: (SelectionOption) -> Void
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

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
        // No outline of its own: the list it sits in is the bubble, and a
        // border here would draw a box inside a box.
        .accessibility(
            label: Text(option.title)
        )
        .accessibilityIdentifier("option.\(option.identifier)")
    }

    private var content: some View {
        HStack(spacing: artwork.size(DesignKitMetrics.Spacing.regular)) {
            Circle()
                .stroke(
                    Color(theme.colors.divider),
                    lineWidth: artwork.stroke(DesignKitMetrics.Stroke.indicator)
                )
                .frame(
                    width: artwork.size(DesignKitMetrics.Size.indicator),
                    height: artwork.size(DesignKitMetrics.Size.indicator)
                )
            Text(option.title)
                .designFont(.body)
                .foregroundColor(Color(theme.colors.primaryText))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(
            maxWidth: .infinity,
            minHeight: artwork.tapTarget(DesignKitMetrics.Size.minimumTapTarget),
            alignment: .leading
        )
    }
}
