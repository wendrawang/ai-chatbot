import SwiftUI

/// One prompt the reply is offering.
///
/// The circle is an affordance, not a state. A tap sends immediately - nothing
/// is held selected and there is no confirm step - so it never shows filled.
public struct TanyaAISuggestionRow: View {
    let suggestion: TanyaAISuggestion
    let onSelect: (TanyaAISuggestion) -> Void
    @Environment(\.tanyaAITheme) private var theme

    public init(
        suggestion: TanyaAISuggestion,
        onSelect: @escaping (TanyaAISuggestion) -> Void
    ) {
        self.suggestion = suggestion
        self.onSelect = onSelect
    }

    public var body: some View {
        Button {
            onSelect(suggestion)
        } label: {
            content
        }
        .background(TanyaAIOutlinedBackground())
        .accessibility(
            label: Text("Suggested question: \(suggestion.title)")
        )
        .accessibilityIdentifier("suggestion.\(suggestion.id)")
    }

    private var content: some View {
        HStack(spacing: DesignKitMetrics.Spacing.regular) {
            Circle()
                .stroke(
                    Color(theme.colors.divider),
                    lineWidth: DesignKitMetrics.Stroke.indicator
                )
                .frame(
                    width: DesignKitMetrics.Size.indicator,
                    height: DesignKitMetrics.Size.indicator
                )
            Text(suggestion.title)
                .font(Font(theme.fonts.body))
                .foregroundColor(Color(theme.colors.primaryText))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, DesignKitMetrics.Spacing.wide)
        .padding(.vertical, DesignKitMetrics.Spacing.regular)
        .frame(minHeight: DesignKitMetrics.Size.minimumTapTarget)
    }
}
