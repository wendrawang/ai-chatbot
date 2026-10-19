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
    private let isResponding: Bool
    private let onSend: (String) -> Bool
    private let onStop: () -> Void

    init(isResponding: Bool, onSend: @escaping (String) -> Bool, onStop: @escaping () -> Void) {
        self.isResponding = isResponding
        self.onSend = onSend
        self.onStop = onStop
    }

    var body: some View {
        MessageComposer(
            text: $draft, placeholder: String(resource: R.string.localizable.chatPlaceholder, locale: locale),
            sendLabel: String(resource: R.string.localizable.chatSend, locale: locale),
            stopLabel: String(resource: R.string.localizable.chatStop, locale: locale),
            isResponding: isResponding, onSend: submit, onStop: onStop
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
