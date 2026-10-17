//
//  ChatScreen.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import DesignKit
import SwiftUI

/// The feature owns its header and draft. Content is injected; there is no chat/session model yet.
@MainActor
public struct ChatScreen<Content: View>: View {
    @Environment(\.locale)
    private var locale
    @Environment(\.dismiss)
    private var dismiss
    @State
    private var text = InitialValues.emptyString
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
            onBack: close, content: { content }, trailing: { moreMenu }, footer: { composer }
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
                .foregroundColor(DefaultColorConstants().colorsIconDark)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(String(resource: R.string.localizable.chatMore, locale: locale))
        .accessibilityIdentifier(ChatElementIdentifier.more)
    }

    private var composer: some View {
        MessageComposer(
            text: $text, placeholder: String(resource: R.string.localizable.chatPlaceholder, locale: locale),
            sendLabel: String(resource: R.string.localizable.chatSend, locale: locale), isEnabled: isEnabled,
            onSend: submit
        )
        .padding(.horizontal, FigmaSize.spacingLarge.scaledToArtwork)
        .padding(.vertical, FigmaSize.spacingMedium.scaledToArtwork)
    }
}

// MARK: - Actions

private extension ChatScreen {
    func close() {
        if let onBack { onBack() } else { dismiss() }
    }

    func submit() {
        guard onSend(text) else { return }
        text = InitialValues.emptyString
    }
}

extension ChatScreen where Content == EmptyView {
    /// Return true when the host accepts the submission; false preserves the draft.
    public init(
        isEnabled: Bool = true, onBack: (() -> Void)? = nil,
        onNewConversation: (() -> Void)? = nil, onSend: @escaping (String) -> Bool
    ) {
        self.init(
            isEnabled: isEnabled, onBack: onBack, onNewConversation: onNewConversation,
            onSend: onSend, content: { EmptyView() }
        )
    }
}
