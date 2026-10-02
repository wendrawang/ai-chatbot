import DesignKit
import TanyaAIDomain
import SwiftUI

/// A question answered by picking chips and confirming.
///
/// The submit button is what separates this from `SuggestionList`, where a tap
/// sends immediately. Anything the customer should be able to change their
/// mind about before it reaches the bot belongs here.
public struct ChoicesBubble: View {
    let payload: ChoicesPayload
    let onToggle: (String) -> Void
    let onSubmit: () -> Void
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork
    @State private var availableWidth: CGFloat = 0

    public init(
        payload: ChoicesPayload,
        onToggle: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        self.payload = payload
        self.onToggle = onToggle
        self.onSubmit = onSubmit
    }

    public var body: some View {
        VStack(
            alignment: .leading,
            spacing: artwork.size(DesignKitMetrics.Spacing.regular)
        ) {
            heading
            chips
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(widthMeasurement)
            submit
        }
        .padding(artwork.size(DesignKitMetrics.Spacing.wide))
        .background(OutlinedBackground())
        .frame(
            maxWidth: artwork.size(DesignKitMetrics.Size.bubbleMaximumWidth),
            alignment: .leading
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("choices.card")
    }

    @ViewBuilder
    private var heading: some View {
        if let title = payload.title, title.isEmpty == false {
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
        let widths = payload.choices.map {
            ChoiceChip.width(
                of: $0,
                isSelected: payload.selected.contains($0.identifier),
                font: theme.fonts.body,
                artwork: artwork
            )
        }
        let rows = ChipLayout.rows(
            widths: widths,
            maxWidth: width,
            spacing: artwork.size(DesignKitMetrics.Spacing.compact)
        )
        return VStack(
            alignment: .leading,
            spacing: artwork.size(DesignKitMetrics.Spacing.compact)
        ) {
            ForEach(rows.indices, id: \.self) { row in
                HStack(spacing: artwork.size(DesignKitMetrics.Spacing.compact)) {
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
            if abs(width - availableWidth) > 0.5 { availableWidth = width }
        }
    }

    private func chip(at index: Int) -> some View {
        let choice = payload.choices[index]
        return ChoiceChip(
            choice: choice,
            isSelected: payload.selected.contains(choice.identifier),
            isEnabled: payload.isSubmitted == false,
            onTap: { onToggle(choice.identifier) }
        )
    }

    private var submit: some View {
        Button(action: onSubmit) {
            Text(payload.submitTitle)
                .designFont(.button)
                .frame(
                    maxWidth: .infinity,
                    minHeight: artwork.tapTarget(DesignKitMetrics.Size.minimumTapTarget)
                )
        }
        .disabled(payload.isSubmittable == false)
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
