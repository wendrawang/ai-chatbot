import SwiftUI

/// The prompts a reply offers, stacked at the end of the conversation.
///
/// In the conversation rather than on a strip above the keyboard: they answer
/// the question just asked, so they belong where that question is, and they
/// scroll away with it once answered.
public struct SuggestionList: View {
    let suggestions: [Suggestion]
    let onSelect: (Suggestion) -> Void

    public init(
        suggestions: [Suggestion],
        onSelect: @escaping (Suggestion) -> Void
    ) {
        self.suggestions = suggestions
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(
            alignment: .leading,
            spacing: DesignKitMetrics.Spacing.compact
        ) {
            ForEach(suggestions) { suggestion in
                SuggestionRow(
                    suggestion: suggestion,
                    onSelect: onSelect
                )
            }
        }
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
}
