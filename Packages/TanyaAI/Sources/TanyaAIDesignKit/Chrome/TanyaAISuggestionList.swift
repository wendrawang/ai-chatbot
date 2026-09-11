import SwiftUI

/// The prompts a reply offers, stacked at the end of the conversation.
///
/// In the conversation rather than on a strip above the keyboard: they are
/// answers to the question just asked, so they belong where that question is,
/// and they scroll away with it once answered.
///
/// The circle is an affordance, not a state. One tap sends - nothing is held
/// selected, and there is no separate confirm step - so it never shows filled.
public struct TanyaAISuggestionList: View {
    let suggestions: [TanyaAISuggestion]
    let onSelect: (TanyaAISuggestion) -> Void
    @Environment(\.tanyaAITheme) private var theme

    public init(
        suggestions: [TanyaAISuggestion],
        onSelect: @escaping (TanyaAISuggestion) -> Void
    ) {
        self.suggestions = suggestions
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(suggestions) { suggestion in
                Button {
                    onSelect(suggestion)
                } label: {
                    row(for: suggestion)
                }
                .background(TanyaAIOutlinedBackground())
                .accessibility(
                    label: Text("Suggested question: \(suggestion.title)")
                )
                .accessibilityIdentifier("suggestion.\(suggestion.id)")
            }
        }
        .frame(maxWidth: 310, alignment: .leading)
        // Without the second frame the 310-wide box is centred in the row and
        // the prompts sit indented from every bubble above them.
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("suggestions.list")
    }

    private func row(for suggestion: TanyaAISuggestion) -> some View {
        HStack(spacing: 12) {
            Circle()
                .stroke(Color(theme.colors.divider), lineWidth: 1.5)
                .frame(width: 20, height: 20)
            Text(suggestion.title)
                .font(Font(theme.fonts.body))
                .foregroundColor(Color(theme.colors.primaryText))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(minHeight: 44)
    }
}
