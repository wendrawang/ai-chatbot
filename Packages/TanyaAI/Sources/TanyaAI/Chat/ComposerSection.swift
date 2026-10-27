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
    @State
    private var draft = String()
    private let isEnabled: Bool
    private let onSend: (String) -> Bool

    init(isEnabled: Bool, onSend: @escaping (String) -> Bool) {
        self.isEnabled = isEnabled
        self.onSend = onSend
    }

    var body: some View {
        MessageComposer(
            text: $draft, placeholder: String(ChatCopy.placeholder, locale: locale),
            sendLabel: String(ChatCopy.send, locale: locale), isEnabled: isEnabled,
            onSend: submit
        )
        .padding(.horizontal, FigmaSize.spacingLarge.scaledToArtwork)
        .padding(.vertical, FigmaSize.spacingMedium.scaledToArtwork)
    }
}

// MARK: - Actions

private extension ComposerSection {
    func submit() {
        guard onSend(draft) else { return }
        draft = String()
    }
}
