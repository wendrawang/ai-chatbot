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
            conversation
            errorBanner
            suggestionStrip
            separator
            TanyaAIChatInputView(viewModel: viewModel)
        }
        .background(Color(theme.colors.background))
    }

    /// The list stays mounted while restoring so it already has its real
    /// size when it is uncovered. Swapping it in only afterwards would hand
    /// it a zero frame and draw the first sizing pass on screen.
    private var conversation: some View {
        ZStack {
            TanyaAIMessageListView(viewModel: viewModel)
            if viewModel.isRestoring {
                TanyaAIRestoringView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var header: some View {
        HStack(spacing: 16) {
            Button(action: viewModel.close) {
                Image(systemName: "xmark")
                    .font(Font(theme.fonts.headline))
                    .frame(width: 44, height: 44)
            }
            .accessibility(label: Text("Close Tanya AI"))

            VStack(alignment: .leading, spacing: 2) {
                Text("Tanya AI")
                    .font(Font(theme.fonts.headline))
                    .foregroundColor(Color(theme.colors.primaryText))
                Text("SANDBOX")
                    .font(Font(theme.fonts.caption))
                    .foregroundColor(Color(theme.colors.secondaryText))
            }

            Spacer()

            Button(action: viewModel.openHistory) {
                Image(systemName: "clock")
                    .font(Font(theme.fonts.headline))
                    .frame(width: 44, height: 44)
            }
            .accessibility(label: Text("Conversation history"))
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .foregroundColor(Color(theme.colors.accent))
    }

    @ViewBuilder
    private var errorBanner: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(Font(theme.fonts.footnote))
                .foregroundColor(Color(theme.colors.error))
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
            .fill(Color(theme.colors.divider))
            .frame(height: 0.5)
    }
}
