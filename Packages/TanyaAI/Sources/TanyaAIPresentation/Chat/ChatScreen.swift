import DesignKit
import SwiftUI
import TanyaAIDomain

public struct ChatScreen: View {
    @Environment(\.artwork) private var artwork
    @Environment(\.copyCatalog) private var copy
    @ObservedObject private var viewModel: TanyaAIChatViewModel
    @Environment(\.theme) private var theme

    public init(viewModel: TanyaAIChatViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            header
            separator
            conversation
            errorBanner
            shortcutStrip
            separator
            MessageComposer(
                text: $viewModel.inputText,
                placeholder: copy.chat("chat.placeholder"),
                sendLabel: copy.chat("chat.send"), stopLabel: copy.chat("chat.stop"),
                isGenerating: viewModel.isGenerating,
                onSend: viewModel.sendCurrentMessage, onStop: viewModel.cancelGeneration
            )
        }
        .background(Color(theme.colors.background))
    }

    /// The list stays mounted while restoring so it already has its real
    /// size when it is uncovered. Swapping it in only afterwards would hand
    /// it a zero frame and draw the first sizing pass on screen.
    private var conversation: some View {
        ZStack {
            MessageListView(viewModel: viewModel)
            if viewModel.isRestoring {
                LoadingStateView(label: copy.chat("chat.loading"))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var header: some View {
        HStack(spacing: artwork.size(DesignKitMetrics.Spacing.wide)) {
            Button(action: viewModel.close) {
                Image(systemName: "xmark")
                    .font(Font(theme.fonts.headline))
                    .frame(width: artwork.tapTarget(), height: artwork.tapTarget())
            }
            .accessibility(label: Text(copy.chat("chat.close")))

            VStack(alignment: .leading, spacing: artwork.size(DesignKitMetrics.Spacing.micro)) {
                Text(copy.chat("chat.title"))
                    .font(Font(theme.fonts.headline))
                    .foregroundColor(Color(theme.colors.primaryText))
                if !copy.chat("chat.subtitle").isEmpty {
                    Text(copy.chat("chat.subtitle"))
                        .font(Font(theme.fonts.caption))
                        .foregroundColor(Color(theme.colors.secondaryText))
                }
            }

            Spacer(minLength: artwork.size(DesignKitMetrics.Spacing.compact))

            Button(action: viewModel.openHistory) {
                Image(systemName: "clock")
                    .font(Font(theme.fonts.headline))
                    .frame(width: artwork.tapTarget(), height: artwork.tapTarget())
            }
            .accessibility(label: Text(copy.chat("chat.history")))
        }
        .padding(.horizontal, artwork.size(DesignKitMetrics.Spacing.compact))
        .padding(.top, artwork.size(DesignKitMetrics.Spacing.compact))
        .foregroundColor(Color(theme.colors.accent))
    }

    @ViewBuilder
    private var errorBanner: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(Font(theme.fonts.footnote))
                .foregroundColor(Color(theme.colors.error))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, artwork.size(DesignKitMetrics.Spacing.wide))
                .padding(.vertical, artwork.size(DesignKitMetrics.Spacing.compact))
        }
    }

    @ViewBuilder
    private var shortcutStrip: some View {
        if viewModel.isShortcutRowVisible {
            OptionStrip(
                options: viewModel.shortcuts.map { SelectionOption(identifier: $0.identifier, title: $0.title) },
                onSelect: { option in
                    if let shortcut = viewModel.shortcuts.first(where: { $0.identifier == option.identifier }) {
                        viewModel.sendShortcut(shortcut)
                    }
                }
            )
        }
    }

    private var separator: some View {
        Rectangle()
            .fill(Color(theme.colors.divider))
            .frame(height: artwork.stroke(DesignKitMetrics.Stroke.divider))
    }
}
