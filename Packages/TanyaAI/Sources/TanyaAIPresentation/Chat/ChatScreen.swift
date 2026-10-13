import DesignKit
import SwiftUI
import TanyaAIDomain

public struct ChatScreen: View {
    @Environment(\.copyCatalog)
    private var copy
    @Environment(\.theme)
    private var theme

    @ObservedObject
    private var viewModel: TanyaAIChatViewModel

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
            ComposerSection(
                isEnabled: viewModel.isSendEnabled,
                draftRequest: viewModel.draftRequest,
                onSend: viewModel.sendMessage
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
                    .accessibilityIdentifier("chat.restoring")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var header: some View {
        HStack(spacing: FigmaSize.spacing16.sizeInArtwork) {
            Button(action: viewModel.close) {
                Image(systemName: "xmark")
                    .designFont(.headline)
                    .frame(
                        width: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork,
                        height: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork
                    )
            }
            .accessibilityLabel(copy.chat("chat.close"))

            VStack(alignment: .leading, spacing: DesignKitMetrics.Spacing.micro.sizeInArtwork) {
                Text(copy.chat("chat.title"))
                    .designFont(.headline)
                    .foregroundColor(Color(theme.colors.primaryText))
                if !copy.chat("chat.subtitle").isEmpty {
                    Text(copy.chat("chat.subtitle"))
                        .designFont(.caption)
                        .foregroundColor(Color(theme.colors.secondaryText))
                }
            }

            Spacer(minLength: FigmaSize.spacing8.sizeInArtwork)

            Button(action: viewModel.openHistory) {
                Image(systemName: "clock")
                    .designFont(.headline)
                    .frame(
                        width: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork,
                        height: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork
                    )
            }
            .accessibilityLabel(copy.chat("chat.history"))
        }
        .padding(.horizontal, FigmaSize.spacing8.sizeInArtwork)
        .padding(.top, FigmaSize.spacing8.sizeInArtwork)
        .foregroundColor(Color(theme.colors.accent))
    }

    @ViewBuilder
    private var errorBanner: some View {
        if let errorMessage = viewModel.errorMessage
            ?? (viewModel.isHistoryUnavailable ? copy.chat("chat.historyUnavailable") : nil)
        {
            HStack(spacing: FigmaSize.spacing8.sizeInArtwork) {
                Text(errorMessage)
                    .designFont(.footnote)
                    .foregroundColor(Color(theme.colors.error))
                Spacer(minLength: 0)
                if viewModel.isSessionRetryAvailable {
                    Button(copy.chat("chat.retry"), action: viewModel.retrySession)
                        .designFont(.button)
                        .frame(minHeight: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork)
                        .disabled(viewModel.connection == .connecting)
                        .accessibilityIdentifier("chat.retrySession")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, FigmaSize.spacing16.sizeInArtwork)
            .padding(.vertical, FigmaSize.spacing8.sizeInArtwork)
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
            .frame(height: DesignKitMetrics.Stroke.divider.strokeInArtwork)
    }
}
