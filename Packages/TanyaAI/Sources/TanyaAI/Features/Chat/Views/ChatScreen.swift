//
//  ChatScreen.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import DesignKit
import SwiftUI

/// The feature owns its header; the draft lives in ComposerSection. Content is injected.
/// `welcome` (dari BE) tampil di atas konten; shortcut yang diketuk dikirim lewat `onSend` seperti chat.
/// Selama `isAwaitingReply`, tombol kirim menjadi titik bergerak dan shortcut nonaktif.
@MainActor
public struct ChatScreen<Content: View>: View {
    @Environment(\.locale)
    private var locale
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.designColors)
    private var colors
    private let isEnabled: Bool
    private let isAwaitingReply: Bool
    private let welcome: WelcomeContent?
    private let onBack: (() -> Void)?
    private let onNewConversation: (() -> Void)?
    private let onSend: (String) -> Bool
    private let content: Content

    public init(
        isEnabled: Bool = true, isAwaitingReply: Bool = false, welcome: WelcomeContent? = nil,
        onBack: (() -> Void)? = nil, onNewConversation: (() -> Void)? = nil, onSend: @escaping (String) -> Bool,
        @ViewBuilder content: () -> Content
    ) {
        self.isEnabled = isEnabled
        self.isAwaitingReply = isAwaitingReply
        self.welcome = welcome
        self.onBack = onBack
        self.onNewConversation = onNewConversation
        self.onSend = onSend
        self.content = content()
    }

    public var body: some View {
        ScreenContainer(
            title: String(ChatCopy.title, locale: locale),
            backLabel: String(ChatCopy.back, locale: locale),
            onBack: close, content: { scrollContent }, trailing: { moreMenu },
            footer: { ComposerSection(isEnabled: isEnabled, isAwaitingReply: isAwaitingReply, onSend: onSend) },
            background: { backgroundImage }
        )
    }

    @ViewBuilder
    private var scrollContent: some View {
        if let welcome {
            WelcomeSection(content: welcome, isEnabled: isEnabled && !isAwaitingReply, onSelect: select)
        }
        content
    }

    /// Menempel di atas layar; bagian bawah yang tidak tertutup gambar memakai warna surface.
    private var backgroundImage: some View {
        Image(ChatImage.chatBackground).resizable().scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .clipped()
    }

    private var moreMenu: some View {
        Menu {
            Button(String(ChatCopy.newConversation, locale: locale)) { onNewConversation?() }
                .disabled(onNewConversation == nil)
        } label: {
            Image(DesignIcon.moreMenu).resizable().scaledToFit()
                .frame(
                    width: FigmaSize.weightIconSmall.scaledToArtwork,
                    height: FigmaSize.weightIconSmall.scaledToArtwork
                )
                .foregroundColor(colors.colorsIconDark)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(String(ChatCopy.more, locale: locale))
        .accessibilityIdentifier(ChatElementIdentifier.more)
    }
}

// MARK: - Actions

private extension ChatScreen {
    func close() {
        if let onBack { onBack() } else { dismiss() }
    }

    /// Shortcut dikirim sebagai chat; hasil diterima/ditolak host tidak mengubah halaman sambutan.
    func select(_ shortcut: WelcomeShortcut) {
        _ = onSend(shortcut.prompt)
    }
}
