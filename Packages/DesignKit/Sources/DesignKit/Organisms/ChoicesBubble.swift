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
            spacing: DesignKitMetrics.Spacing.regular
        ) {
            heading
            chips
            submit
        }
        .padding(DesignKitMetrics.Spacing.wide)
        .background(OutlinedBackground())
        .frame(
            maxWidth: DesignKitMetrics.Size.bubbleMaximumWidth,
            alignment: .leading
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("choices.card")
    }

    @ViewBuilder
    private var heading: some View {
        if let title = payload.title, title.isEmpty == false {
            Text(title)
                .font(Font(theme.fonts.headline))
                .foregroundColor(Color(theme.colors.primaryText))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// Rows are packed from measured widths rather than left to SwiftUI, so
    /// the wrapping is decided once and can be asserted on. See `ChipLayout`.
    private var chips: some View {
        let width = DesignKitMetrics.Size.bubbleMaximumWidth
            - DesignKitMetrics.Spacing.wide * 2
        let widths = payload.choices.map {
            ChoiceChip.width(of: $0, font: theme.fonts.body)
        }
        let rows = ChipLayout.rows(
            widths: widths,
            maxWidth: width,
            spacing: DesignKitMetrics.Spacing.compact
        )
        return VStack(
            alignment: .leading,
            spacing: DesignKitMetrics.Spacing.compact
        ) {
            ForEach(rows.indices, id: \.self) { row in
                HStack(spacing: DesignKitMetrics.Spacing.compact) {
                    ForEach(rows[row], id: \.self) { index in
                        chip(at: index)
                    }
                }
            }
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
                .font(Font(theme.fonts.button))
                .frame(
                    maxWidth: .infinity,
                    minHeight: DesignKitMetrics.Size.minimumTapTarget
                )
        }
        .disabled(payload.canSubmit == false)
        .foregroundColor(Color(theme.colors.userBubbleText))
        .background(
            RoundedRectangle(cornerRadius: DesignKitMetrics.Radius.bubble)
                .fill(Color(theme.colors.accent))
                // Dimmed rather than hidden: a button that disappears until
                // something is picked leaves the customer unsure there is a
                // next step at all.
                .opacity(payload.canSubmit ? 1 : 0.35)
        )
        .accessibilityIdentifier("choices.submit")
    }
}
