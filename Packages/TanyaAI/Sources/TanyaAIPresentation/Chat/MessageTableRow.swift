import DesignKit
import SwiftUI
import TanyaAIDomain

struct MessageTableRow: View {
    let kind: TanyaAIMessageRowKind
    let theme: Theme
    let handlers: TanyaAIMessageRowHandlers
    var copy = CopyCatalog()
    var artwork = ArtworkMetrics()
    var imageLoader: ImageLoading = ImageLoader.shared

    var body: some View {
        Group {
            switch kind {
            case .message(let message):
                MessageRowView(
                    viewModel: message,
                    handlers: handlers
                )
                .id(message.identifier)
            case .typing:
                TypingIndicatorView(label: copy.chat("chat.responding"))
            case .suggestions(let title, let suggestions):
                OptionList(
                    title: title,
                    options: suggestions.map { SelectionOption(identifier: $0.identifier, title: $0.title) },
                    onSelect: { option in
                        if let suggestion = suggestions.first(where: { $0.identifier == option.identifier }) {
                            handlers.onSuggestion(suggestion)
                        }
                    }
                )
            }
        }
        .padding(.horizontal, artwork.size(DesignKitMetrics.Spacing.wide))
        .padding(.vertical, artwork.size(DesignKitMetrics.Spacing.snug))
        .theme(theme)
        .artwork(artwork)
        .imageLoader(imageLoader)
        .copyCatalog(copy)
    }
}
