import SwiftUI

struct TanyaAISuggestionStrip: View {
    let suggestions: [TanyaAISuggestion]
    let onSelect: (TanyaAISuggestion) -> Void
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(suggestions) { suggestion in
                    Button(
                        action: { onSelect(suggestion) },
                        label: {
                            Text(suggestion.title)
                                .font(Font(theme.fonts.button))
                                .padding(.horizontal, 14)
                                .frame(minHeight: 44)
                        }
                    )
                    .foregroundColor(Color(theme.colors.accent))
                    .background(Color(theme.colors.surface))
                    .cornerRadius(22)
                    .accessibility(
                        label: Text("Suggested question: \(suggestion.title)")
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

}
