import DesignKit
import SwiftUI
import TanyaAIDomain

struct MessageTableRow: View {
    let kind: TanyaAIMessageRowKind
    let theme: Theme
    let handlers: TanyaAIMessageRowHandlers
    var copy = CopyCatalog()

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
                ActivityStatus(text: copy.chat("chat.responding"))
                    .accessibilityIdentifier("chat.typing")
            case .timestamp(let timestamp):
                Text(timestamp)
                    .designFont(.caption)
                    .foregroundColor(Color(theme.colors.secondaryText))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, FigmaSize.spacing8.sizeInArtwork)
                    .accessibilityIdentifier("chat.timestamp")
            }
        }
        .padding(.horizontal, FigmaSize.spacing16.sizeInArtwork)
        .padding(.vertical, DesignKitMetrics.Spacing.snug.sizeInArtwork)
        .theme(theme)
        .copyCatalog(copy)
    }
}
