//
//  ComposerSection.swift
//  TanyaAI
//
//  Created by Wendra on 17/10/26.
//

import DesignKit
import SwiftUI

/// Draft hidup di sini agar setiap ketikan hanya me-render composer, bukan seluruh screen/daftar pesan.
/// Draft dikosongkan saat pesan terkirim muncul di stream, bukan saat tombol kirim ditekan.
@MainActor
struct ComposerSection: View {
    @Environment(\.locale)
    private var locale
    @State
    private var draft = String()
    /// Teks yang sedang dikirim; draft hanya dikosongkan bila belum diubah sejak itu.
    @State
    private var submitted: String?
    private let action: ComposerAction
    private let isEnabled: Bool
    private let deliveredQuestionId: String?
    private let onSend: (String) -> Bool
    private let onStop: () -> Void

    init(
        action: ComposerAction, isEnabled: Bool, deliveredQuestionId: String?, onSend: @escaping (String) -> Bool,
        onStop: @escaping () -> Void
    ) {
        self.action = action
        self.isEnabled = isEnabled
        self.deliveredQuestionId = deliveredQuestionId
        self.onSend = onSend
        self.onStop = onStop
    }

    var body: some View {
        MessageComposer(
            text: $draft, placeholder: String(resource: R.string.localizable.chatPlaceholder, locale: locale),
            sendLabel: String(resource: R.string.localizable.chatSend, locale: locale),
            stopLabel: String(resource: R.string.localizable.chatStop, locale: locale), action: action,
            isEnabled: isEnabled, onSend: submit, onStop: onStop
        )
        .padding(.horizontal, FigmaSize.spacingLarge.scaledToArtwork)
        .padding(.vertical, FigmaSize.spacingMedium.scaledToArtwork)
        .onChange(of: deliveredQuestionId) { _ in clearSubmitted() }
    }
}

// MARK: - Actions

private extension ComposerSection {
    func submit() {
        guard onSend(draft) else { return }
        submitted = draft
    }

    func clearSubmitted() {
        if draft == submitted { draft = String() }
        submitted = nil
    }
}
