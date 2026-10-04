import SwiftUI

/// A question answered by picking chips and confirming.
///
/// The submit button is what separates this from `OptionList`, where a tap
/// reports a selection immediately. This group allows changes before submission.
public struct ChoiceGroup: View {
    let title: String?
    let options: [SelectionOption]
    let selected: Set<String>
    let isEnabled: Bool
    let isSubmittable: Bool
    let submitTitle: String
    let onToggle: (String) -> Void
    let onSubmit: () -> Void
    @Environment(\.theme) private var theme

    @State private var availableWidth: CGFloat = 0

    public init(
        title: String?, options: [SelectionOption], selected: Set<String>,
        isEnabled: Bool, isSubmittable: Bool, submitTitle: String,
        onToggle: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        self.title = title
        self.options = options
        self.selected = selected
        self.isEnabled = isEnabled
        self.isSubmittable = isSubmittable
        self.submitTitle = submitTitle
        self.onToggle = onToggle
        self.onSubmit = onSubmit
    }

    public var body: some View {
        VStack(
            alignment: .leading,
            spacing: DesignKitMetrics.Spacing.regular.sizeInArtwork
        ) {
            heading
            chips
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(widthMeasurement)
            submit
        }
        .padding(DesignKitMetrics.Spacing.wide.sizeInArtwork)
        .background(OutlinedBackground())
        .frame(
            maxWidth: DesignKitMetrics.Size.bubbleMaximumWidth.sizeInArtwork,
            alignment: .leading
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("choices.card")
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

    /// Rows are packed from measured widths rather than left to SwiftUI, so
    /// the wrapping is decided once and can be asserted on. See `ChipLayout`.
    private var chips: some View {
        let width = availableWidth
        let widths = options.map {
            SelectionChip.width(
                of: $0.title,
                isSelected: selected.contains($0.identifier),
                font: theme.fonts.body
            )
        }
        let rows = ChipLayout.rows(
            widths: widths,
            maxWidth: width,
            spacing: DesignKitMetrics.Spacing.compact.sizeInArtwork
        )
        return VStack(
            alignment: .leading,
            spacing: DesignKitMetrics.Spacing.compact.sizeInArtwork
        ) {
            ForEach(rows.indices, id: \.self) { row in
                HStack(spacing: DesignKitMetrics.Spacing.compact.sizeInArtwork) {
                    ForEach(rows[row], id: \.self) { index in
                        chip(at: index)
                    }
                }
            }
        }
    }

    private var widthMeasurement: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: ChoiceWidthKey.self, value: proxy.size.width)
        }
        .onPreferenceChange(ChoiceWidthKey.self) { width in
            if abs(width - availableWidth) > DesignKitMetrics.Layout.measurementTolerance { availableWidth = width }
        }
    }

    private func chip(at index: Int) -> some View {
        let choice = options[index]
        return SelectionChip(
            title: choice.title,
            isSelected: selected.contains(choice.identifier),
            isEnabled: isEnabled,
            onTap: { onToggle(choice.identifier) }
        )
        .accessibilityIdentifier("choice.\(choice.identifier)")
    }

    private var submit: some View {
        Button(action: onSubmit) {
            Text(submitTitle)
                .designFont(.button)
                .frame(
                    maxWidth: .infinity,
                    minHeight: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork
                )
        }
        .disabled(!isEnabled || !isSubmittable)
        .buttonStyle(DesignButtonStyle())
        .accessibilityIdentifier("choices.submit")
    }
}

private struct ChoiceWidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
