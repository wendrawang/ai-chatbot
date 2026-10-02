import DesignKit
import SwiftUI
import TanyaAIDomain

struct TanyaAIMessageTableRow: View {
    let kind: TanyaAIMessageRowKind
    let theme: Theme
    let handlers: TanyaAIMessageRowHandlers
    var artwork = ArtworkMetrics()
    var imageLoader: ImageLoading = ImageLoader.shared

    var body: some View {
        Group {
            switch kind {
            case .message(let message):
                TanyaAIMessageRowView(
                    viewModel: message,
                    handlers: handlers
                )
                .id(message.identifier)
            case .typing:
                TypingIndicatorView()
            case .suggestions(let title, let suggestions):
                SuggestionList(
                    title: title,
                    suggestions: suggestions,
                    onSelect: handlers.onSuggestion
                )
            }
        }
        .padding(.horizontal, artwork.size(DesignKitMetrics.Spacing.wide))
        .padding(.vertical, artwork.size(DesignKitMetrics.Spacing.snug))
        .theme(theme)
        .artwork(artwork)
        .imageLoader(imageLoader)
    }
}
