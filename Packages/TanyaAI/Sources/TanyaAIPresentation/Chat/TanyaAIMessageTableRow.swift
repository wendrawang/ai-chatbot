import SwiftUI
import TanyaAIDesignKit
import TanyaAIDesignSystem
import TanyaAIDomain

struct TanyaAIMessageTableRow: View {
    let kind: TanyaAIMessageRowKind
    let theme: TanyaAITheme
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
                TanyaAITypingIndicatorView()
            case .suggestions(let suggestions):
                TanyaAISuggestionList(
                    suggestions: suggestions,
                    onSelect: handlers.onSuggestion
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .tanyaAITheme(theme)
    }
}
