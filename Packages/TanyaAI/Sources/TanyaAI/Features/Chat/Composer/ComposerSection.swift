//
//  ComposerSection.swift
//  TanyaAI
//
//  Created by Wendra on 17/10/26.
//

import DesignKit
import SwiftUI

/// Draft hidup di sini agar setiap ketikan hanya me-render composer, bukan seluruh screen/daftar pesan.
@MainActor
struct ComposerSection: View {
    @Environment(\.locale)
    private var locale
    @Environment(\.designColors)
    private var colors
    @State
    private var draft = String()
    private let isEnabled: Bool
    private let isAwaitingReply: Bool
    private let onSend: (String) -> Bool

    init(isEnabled: Bool, isAwaitingReply: Bool, onSend: @escaping (String) -> Bool) {
        self.isEnabled = isEnabled
        self.isAwaitingReply = isAwaitingReply
        self.onSend = onSend
    }

    var body: some View {
        VStack(spacing: .zero) {
            divider
            MessageComposer(
                text: $draft, placeholder: String(ChatCopy.placeholder, locale: locale),
                sendLabel: String(isAwaitingReply ? ChatCopy.replying : ChatCopy.send, locale: locale),
                isEnabled: isEnabled, isLoading: isAwaitingReply, onSend: submit
            )
            .padding(FigmaSize.spacingLarge.scaledToArtwork)
        }
    }

    /// Garis selebar layar di atas composer (Figma), memisahkan area chat dari input.
    private var divider: some View {
        colors.colorsOutlineNetral
            .frame(height: FigmaSize.weightOutline.scaledToArtwork)
            .accessibilityHidden(true)
    }
}

// MARK: - Actions

private extension ComposerSection {
    func submit() {
        guard onSend(draft) else { return }
        draft = String()
    }
}
