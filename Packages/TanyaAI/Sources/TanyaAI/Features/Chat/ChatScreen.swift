//
//  ChatScreen.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import DesignKit
import SwiftUI

/// The feature owns its header; the draft lives in ComposerSection. Content is injected.
/// `welcome` (dari BE) tampil di atas konten; shortcut yang diketuk dikirim lewat `bridge` seperti chat.
/// Selama `bridge` menunggu jawaban, tombol kirim menjadi titik bergerak dan shortcut nonaktif.
@MainActor
public struct ChatScreen<Content: View>: View {
    @Environment(\.locale)
    private var locale
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.designColors)
    private var colors
    @ObservedObject
    private var bridge: TanyaAIBridge
    private let isEnabled: Bool
    private let welcome: WelcomeContent?
    private let onBack: (() -> Void)?
    private let content: Content

    public init(
        isEnabled: Bool = true, welcome: WelcomeContent? = nil, bridge: TanyaAIBridge,
        onBack: (() -> Void)? = nil, @ViewBuilder content: () -> Content
    ) {
        _bridge = ObservedObject(wrappedValue: bridge)
        self.isEnabled = isEnabled
        self.welcome = welcome
        self.onBack = onBack
        self.content = content()
    }

    public var body: some View {
        ScreenContainer(
            title: String(ChatCopy.title, locale: locale),
            backLabel: String(ChatCopy.back, locale: locale),
            onBack: close, content: { scrollContent }, trailing: { moreMenu },
            footer: { composer },
            background: { backgroundImage }
        )
    }

    @ViewBuilder
    private var scrollContent: some View {
        if let welcome {
            WelcomeSection(content: welcome, isEnabled: isEnabled && !bridge.isAwaitingReply, onSelect: select)
        }
        content
    }

    private var composer: some View {
        ComposerSection(isEnabled: isEnabled, isAwaitingReply: bridge.isAwaitingReply) { [bridge] text in
            bridge.send(text)
        }
    }

    /// Menempel di atas layar selebar layar; bagian bawah yang tidak tertutup gambar memakai warna surface.
    /// Sengaja `scaledToFit`, bukan `scaledToFill` + `clipped`: di iOS 17 kombinasi itu membuat latar dan isi scroll
    /// hilang (putih) selama swipe back interaktif di host.
    private var backgroundImage: some View {
        Image(ChatImage.chatBackground).resizable()
            .scaledToFit()
            .frame(maxHeight: .infinity, alignment: .top)
    }

    private var moreMenu: some View {
        Menu {
            Button(String(ChatCopy.newConversation, locale: locale)) { bridge.startNewConversation() }
                .disabled(!bridge.isNewConversationAvailable)
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
        _ = bridge.send(shortcut.prompt)
    }
}
