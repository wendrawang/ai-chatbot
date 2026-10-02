import DesignKit
import TanyaAIDomain
import SwiftUI

/// One prompt the reply is offering.
///
/// The circle is an affordance, not a state. A tap sends immediately - nothing
/// is held selected and there is no confirm step - so it never shows filled.
public struct SuggestionRow: View {
    let suggestion: Suggestion
    let onSelect: (Suggestion) -> Void
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

    public init(
        suggestion: Suggestion,
        onSelect: @escaping (Suggestion) -> Void
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
        // No outline of its own: the list it sits in is the bubble, and a
        // border here would draw a box inside a box.
        .accessibility(
            label: Text(String(format: ChatCopy.text("Suggested question: %@"), suggestion.title))
        )
        .accessibilityIdentifier("suggestion.\(suggestion.identifier)")
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
            Text(suggestion.title)
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
