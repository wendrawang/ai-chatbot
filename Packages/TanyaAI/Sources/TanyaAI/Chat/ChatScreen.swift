//
//  ChatScreen.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import DesignKit
import SwiftUI

/// Halaman Tanya AI: header, welcome atau daftar pesan, dan composer.
@MainActor
struct ChatScreen: View {
    @Environment(\.locale)
    private var locale
    @Environment(\.designColors)
    private var colors
    @Environment(\.dismiss)
    private var dismiss
    @StateObject
    private var viewModel: ChatViewModel
    @State
    private var isScrolled = false
    @State
    private var isAtBottom = true
    @State
    private var scrollRequest = UUID()
    private let customerName: String
    private let onBack: (() -> Void)?

    init(viewModel: @autoclosure @escaping () -> ChatViewModel, customerName: String, onBack: (() -> Void)?) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.customerName = customerName
        self.onBack = onBack
    }

    var body: some View {
        VStack(spacing: .zero) {
            ZStack(alignment: .top) {
                content
                ScreenHeader(
                    title: String(resource: R.string.localizable.chatTitle, locale: locale),
                    backLabel: String(resource: R.string.localizable.chatBack, locale: locale),
                    isScrolled: isScrolled && !viewModel.messages.isEmpty, onBack: close, trailing: { moreMenu }
                )
            }
            .overlay(alignment: .bottom) { scrollToLatest }
            colors.colorsOutlineNetral.frame(height: FigmaSize.weightOutline.scaledToArtwork)
            ComposerSection(isResponding: viewModel.isResponding, onSend: viewModel.send, onStop: viewModel.stop)
        }
        .background(background)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.messages.isEmpty {
            WelcomeView(customerName: customerName, topInset: CustomSizes.Header.height.scaledToArtwork) { action in
                viewModel.send(action.prompt(locale: locale))
            }
        } else {
            MessageList(
                isScrolled: $isScrolled, isAtBottom: $isAtBottom, messages: viewModel.messages, handlers: handlers,
                scrollRequest: scrollRequest, topInset: CustomSizes.Header.height.scaledToArtwork
            )
        }
    }

    @ViewBuilder
    private var scrollToLatest: some View {
        if !isAtBottom && !viewModel.messages.isEmpty {
            ScrollToLatestButton(label: String(resource: R.string.localizable.chatScrollToLatest, locale: locale)) {
                scrollRequest = UUID()
            }
            .padding(.bottom, FigmaSize.spacingMedium.scaledToArtwork)
        }
    }

    private var moreMenu: some View {
        Menu {
            Button(String(resource: R.string.localizable.chatNewConversation, locale: locale)) {
                viewModel.startNewConversation()
            }
            .disabled(viewModel.messages.isEmpty)
        } label: {
            Image(DesignKit.R.image.moreMenu).resizable().scaledToFit()
                .frame(
                    width: FigmaSize.weightIconSmall.scaledToArtwork, height: FigmaSize.weightIconSmall.scaledToArtwork
                )
                .foregroundColor(colors.colorsIconDark)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(String(resource: R.string.localizable.chatMore, locale: locale))
        .accessibilityIdentifier(ChatElementIdentifier.more)
    }

    private var background: some View {
        colors.colorsSurfacePrimary
            .overlay(alignment: .top) { Image(R.image.chatBackground).resizable().scaledToFit() }
            .ignoresSafeArea()
    }
}

// MARK: - Actions

private extension ChatScreen {
    /// Tanpa `onBack` dari host, kembali memakai `dismiss` SwiftUI (pop pada navigasi host).
    func close() {
        if let onBack { onBack() } else { dismiss() }
    }
}

// MARK: - Helpers

private extension ChatScreen {
    var handlers: MessageHandlers {
        MessageHandlers(
            perform: { [weak viewModel] action, label in viewModel?.perform(action, label: label) },
            select: { [weak viewModel] item, block, message in
                viewModel?.select(item, blockIndex: block, messageId: message)
            },
            openLink: { [weak viewModel] url in viewModel?.openLink(url) }
        )
    }
}
