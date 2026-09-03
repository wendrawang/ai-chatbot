import SwiftUI
import TanyaAIDesignSystem
import TanyaAIDomain

struct TanyaAIMessageTableRow: View {
    let message: TanyaAIMessageItemViewModel?
    let theme: TanyaAITheme
    let handlers: TanyaAIMessageRowHandlers

    var body: some View {
        Group {
            if let message = message {
                TanyaAIMessageRowView(
                    viewModel: message,
                    handlers: handlers
                )
            } else {
                TanyaAITypingIndicatorView()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .tanyaAITheme(theme)
    }
}
