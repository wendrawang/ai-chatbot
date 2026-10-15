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
            separator
            ComposerSection(
                isEnabled: viewModel.isSendEnabled,
                draftRequest: viewModel.draftRequest,
                onSend: viewModel.sendMessage
            )
            .id(viewModel.sessionIdentifier)
        }
        .background(ChatBackdrop())
    }

    /// The list stays mounted while restoring so it already has its real
    /// size when it is uncovered. Swapping it in only afterwards would hand
    /// it a zero frame and draw the first sizing pass on screen.
    private var conversation: some View {
        ZStack {
            MessageListView(viewModel: viewModel)
            if !viewModel.isRestoring, viewModel.messages.isEmpty, let welcome = viewModel.welcome {
                WelcomeSection(configuration: welcome) { action in
                    viewModel.sendMessage(action.title)
                }
                .disabled(!viewModel.isSendEnabled)
            }
            if viewModel.isRestoring {
                LoadingStateView(label: copy.chat("chat.loading"))
                    .accessibilityIdentifier("chat.restoring")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var header: some View {
        NavigationHeader(title: copy.chat("chat.title")) {
            Button(action: viewModel.close) {
                headerIcon("chevron.left")
            }
            .foregroundColor(Color(theme.colors.accent))
            .accessibilityLabel(copy.chat("chat.close"))
            .accessibilityIdentifier("chat.close")
        } trailing: {
            headerAction
        }
        .accessibilityIdentifier("chat.header")
    }

    private var headerAction: some View {
        Button(action: viewModel.startNewSession) {
            headerIcon("ellipsis").rotationEffect(.degrees(90))
        }
        .foregroundColor(Color(theme.colors.primaryText))
        .disabled(!viewModel.isNewSessionEnabled)
        .accessibilityLabel(copy.chat("chat.newSession"))
        .accessibilityIdentifier("chat.newSession")
    }

    private func headerIcon(_ name: String) -> some View {
        Image(systemName: name)
            .resizable()
            .scaledToFit()
            .frame(
                width: DesignKitMetrics.Size.icon.sizeInArtwork,
                height: DesignKitMetrics.Size.icon.sizeInArtwork
            )
            .frame(
                width: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork,
                height: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork
            )
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

    private var separator: some View {
        Rectangle()
            .fill(Color(theme.colors.divider))
            .frame(height: DesignKitMetrics.Stroke.divider.strokeInArtwork)
    }
}
