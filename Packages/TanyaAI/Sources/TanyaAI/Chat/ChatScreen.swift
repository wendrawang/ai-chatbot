//
//  ChatScreen.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import DesignKit
import SwiftUI

/// Halaman Tanya AI: header, daftar pesan, status koneksi, pesan gagal, dan composer.
/// Draft hidup di `ComposerSection`; percakapan dimiliki `ChatViewModel`.
@MainActor
struct ChatScreen: View {
    @Environment(\.locale)
    private var locale
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.designColors)
    private var colors
    @StateObject
    private var viewModel: ChatViewModel
    @State
    private var isScrolled = false
    private let onBack: (() -> Void)?
    private let onNewConversation: (() -> Void)?

    init(
        viewModel: @autoclosure @escaping () -> ChatViewModel, onBack: (() -> Void)?,
        onNewConversation: (() -> Void)?
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onBack = onBack
        self.onNewConversation = onNewConversation
    }

    var body: some View {
        VStack(spacing: .zero) {
            ZStack(alignment: .top) {
                MessageList(
                    isScrolled: $isScrolled, messages: viewModel.messages, welcome: viewModel.welcome,
                    isShortcutEnabled: viewModel.isShortcutEnabled, isReplying: viewModel.turn.isReplying,
                    handlers: handlers,
                    topInset: CustomSizes.Header.height.scaledToArtwork + FigmaSize.spacingLarge.scaledToArtwork
                )
                ScreenHeader(
                    title: String(resource: R.string.localizable.chatTitle, locale: locale),
                    backLabel: String(resource: R.string.localizable.chatBack, locale: locale),
                    isScrolled: isScrolled, onBack: close, trailing: { moreMenu }
                )
            }
            if viewModel.phase != .ready {
                ConnectionBanner(isFailed: viewModel.phase == .failed, onRetry: viewModel.retry)
            }
            if let notice = viewModel.notice {
                NoticeLabel(notice: notice)
            }
            ComposerSection(
                action: composerAction, isEnabled: viewModel.phase == .ready,
                deliveredQuestionId: viewModel.deliveredQuestionId, onSend: viewModel.send, onStop: viewModel.stop
            )
        }
        .background(colors.colorsSurfacePrimary.ignoresSafeArea())
        .onAppear(perform: viewModel.start)
    }

    private var moreMenu: some View {
        Menu {
            Button(String(resource: R.string.localizable.chatNewConversation, locale: locale)) { onNewConversation?() }
                .disabled(onNewConversation == nil)
        } label: {
            Image(DesignKit.R.image.moreMenu).resizable().scaledToFit()
                .frame(
                    width: FigmaSize.weightIconSmall.scaledToArtwork,
                    height: FigmaSize.weightIconSmall.scaledToArtwork
                )
                .foregroundColor(colors.colorsIconDark)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(String(resource: R.string.localizable.chatMore, locale: locale))
        .accessibilityIdentifier(ChatElementIdentifier.more)
    }
}

// MARK: - Actions

private extension ChatScreen {
    func close() {
        if let onBack { onBack() } else { dismiss() }
    }

    var composerAction: ComposerAction {
        switch viewModel.turn {
        case .idle: return .send
        case .sending: return .sending
        case .waiting, .stopping: return .stop
        }
    }

    var handlers: MessageHandlers {
        MessageHandlers(
            shortcut: { [weak model = viewModel] text in _ = model?.send(text) },
            loadOlder: { [weak model = viewModel] in model?.loadOlder() }
        )
    }
}
