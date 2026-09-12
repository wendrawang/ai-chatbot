import DesignKit
import SwiftUI
import TanyaAIDomain

struct TanyaAIMessageTableRow: View {
    let kind: TanyaAIMessageRowKind
    let theme: Theme
    let handlers: TanyaAIMessageRowHandlers

    var body: some View {
        Group {
            switch kind {
            case .message(let message):
                TanyaAIMessageRowView(
                    viewModel: message,
                    handlers: handlers
                )
            case .typing:
                TypingIndicatorView()
            case .suggestions(let suggestions):
                SuggestionList(
                    suggestions: suggestions,
                    onSelect: handlers.onSuggestion
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .theme(theme)
    }
}
