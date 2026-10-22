//
//  ChatScreen.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import DesignKit
import SwiftUI

/// The feature owns its header; the draft lives in ComposerSection. Content is injected.
@MainActor
public struct ChatScreen<Content: View>: View {
    @Environment(\.locale)
    private var locale
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.designColors)
    private var colors
    private let isEnabled: Bool
    private let onBack: (() -> Void)?
    private let onNewConversation: (() -> Void)?
    private let onSend: (String) -> Bool
    private let content: Content

    public init(
        isEnabled: Bool = true, onBack: (() -> Void)? = nil,
        onNewConversation: (() -> Void)? = nil, onSend: @escaping (String) -> Bool,
        @ViewBuilder content: () -> Content
    ) {
        self.isEnabled = isEnabled
        self.onBack = onBack
        self.onNewConversation = onNewConversation
        self.onSend = onSend
        self.content = content()
    }

    public var body: some View {
        ScreenContainer(
            title: String(resource: R.string.localizable.chatTitle, locale: locale),
            backLabel: String(resource: R.string.localizable.chatBack, locale: locale),
            onBack: close, content: { content }, trailing: { moreMenu },
            footer: { ComposerSection(isEnabled: isEnabled, onSend: onSend) }
        )
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
}
