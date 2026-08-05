import SwiftUI
import TanyaAIDomain

public struct TanyaAIChatView: View {
    @ObservedObject private var viewModel: TanyaAIChatViewModel
    @Environment(\.tanyaAITheme) private var theme

    public init(viewModel: TanyaAIChatViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            header
            separator
            TanyaAIMessageListView(viewModel: viewModel)
            errorBanner
            suggestionStrip
            separator
            TanyaAIChatInputView(viewModel: viewModel)
        }
        .background(theme.colors.background)
    }

    private var header: some View {
        HStack(spacing: 16) {
            Button(action: viewModel.close) {
                Image(systemName: "xmark")
                    .font(theme.fonts.headline)
                    .frame(width: 44, height: 44)
            }
            .accessibility(label: Text("Close Tanya AI"))

            VStack(alignment: .leading, spacing: 2) {
                Text("Tanya AI")
                    .font(theme.fonts.headline)
                    .foregroundColor(theme.colors.primaryText)
                Text("SANDBOX")
                    .font(theme.fonts.caption)
                    .foregroundColor(theme.colors.secondaryText)
            }

            Spacer()

            Button(action: viewModel.openHistory) {
                Image(systemName: "clock")
                    .font(theme.fonts.headline)
                    .frame(width: 44, height: 44)
            }
            .accessibility(label: Text("Conversation history"))
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .foregroundColor(theme.colors.accent)
    }

    @ViewBuilder
    private var errorBanner: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(theme.fonts.footnote)
                .foregroundColor(theme.colors.error)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private var suggestionStrip: some View {
        if viewModel.showsSuggestions {
            TanyaAISuggestionStrip(
                suggestions: viewModel.suggestions,
                onSelect: viewModel.sendSuggestion
            )
        }
    }

    private var separator: some View {
        Rectangle()
            .fill(theme.colors.divider)
            .frame(height: 0.5)
    }
}
