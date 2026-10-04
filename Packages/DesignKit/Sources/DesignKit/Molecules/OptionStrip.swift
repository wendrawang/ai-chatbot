import SwiftUI

/// A horizontal row of options with stable identifiers.
public struct OptionStrip: View {
    let options: [SelectionOption]
    let onSelect: (SelectionOption) -> Void
    @Environment(\.theme) private var theme

    public init(
        options: [SelectionOption],
        onSelect: @escaping (SelectionOption) -> Void
    ) {
        self.options = options
        self.onSelect = onSelect
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignKitMetrics.Spacing.compact.sizeInArtwork) {
                ForEach(options, id: \.identifier) { option in
                    Button(
                        action: { onSelect(option) },
                        label: { label(option) }
                    )
                    .foregroundColor(Color(theme.colors.accent))
                    .background(pill)
                    .accessibilityIdentifier("option.\(option.identifier)")
                    .accessibility(
                        label: Text(option.title)
                    )
                }
            }
            .padding(.horizontal, DesignKitMetrics.Spacing.regular.sizeInArtwork)
            .padding(.vertical, DesignKitMetrics.Spacing.compact.sizeInArtwork)
        }
        .accessibilityIdentifier("options.strip")
    }

    private func label(_ option: SelectionOption) -> some View {
        Text(option.title)
            .designFont(.button)
            .lineLimit(1)
            .padding(.horizontal, DesignKitMetrics.Spacing.wide.sizeInArtwork)
            .frame(minHeight: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork)
    }

    private var pill: some View {
        Capsule()
            .fill(Color(theme.colors.assistantBubble))
            .overlay(
                Capsule().stroke(
                    Color(theme.colors.divider),
                    lineWidth: DesignKitMetrics.Stroke.hairline.strokeInArtwork
                )
            )
    }
}
