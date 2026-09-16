import SwiftUI

/// The prompts a reply offers, as one bubble at the end of the conversation.
///
/// In the conversation rather than on a strip above the keyboard: they answer
/// the question just asked, so they belong where that question is, and they
/// scroll away with it once answered.
///
/// One tap sends. There is no confirm step here - that is what `ChoicesBubble`
/// is for, and the presence or absence of a submit button is the whole of the
/// difference between the two.
public struct SuggestionList: View {
    let title: String?
    let suggestions: [Suggestion]
    let onSelect: (Suggestion) -> Void
    @Environment(\.theme) private var theme

    public init(
        title: String?,
        suggestions: [Suggestion],
        onSelect: @escaping (Suggestion) -> Void
    ) {
        self.title = title
        self.suggestions = suggestions
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(
            alignment: .leading,
            spacing: DesignKitMetrics.Spacing.regular
        ) {
            heading
            rows
        }
        .padding(DesignKitMetrics.Spacing.wide)
        .background(OutlinedBackground())
        .frame(
            maxWidth: DesignKitMetrics.Size.bubbleMaximumWidth,
            alignment: .leading
        )
        // Without the second frame the box is centred in the row and the
        // prompts sit indented from every bubble above them.
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("suggestions.list")
    }

    @ViewBuilder
    private var heading: some View {
        if let title = title, title.isEmpty == false {
            Text(title)
                .font(Font(theme.fonts.headline))
                .foregroundColor(Color(theme.colors.primaryText))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var rows: some View {
        VStack(
            alignment: .leading,
            spacing: DesignKitMetrics.Spacing.compact
        ) {
            ForEach(suggestions, id: \.identifier) { suggestion in
                SuggestionRow(suggestion: suggestion, onSelect: onSelect)
            }
        }
    }
}
