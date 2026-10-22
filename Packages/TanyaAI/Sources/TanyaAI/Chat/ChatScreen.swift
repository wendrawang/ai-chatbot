//
//  ChatScreen.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import DesignKit
import SwiftUI

/// Halaman Tanya AI: header, daftar pesan, status koneksi, dan composer.
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
                    isScrolled: $isScrolled, messages: viewModel.messages, isReplying: viewModel.isReplying,
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
            ComposerSection(isEnabled: viewModel.phase == .ready, onSend: viewModel.send)
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

    var handlers: MessageHandlers {
        MessageHandlers(
            resend: { [weak model = viewModel] id in model?.resend(id) },
            loadOlder: { [weak model = viewModel] in model?.loadOlder() }
        )
    }
}
