//
//  MessageRow.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import DesignKit
import SwiftUI

/// Satu baris daftar: tanggal (bila hari baru), bubble pengguna atau jawaban berblok.
@MainActor
struct MessageRow: View {
    @Environment(\.locale)
    private var locale
    let message: ChatMessage
    let handlers: MessageHandlers

    var body: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacingLarge.scaledToArtwork) {
            if message.isDateVisible {
                DateSeparator(ChatDateFormat.text(for: message.createdAt, locale: locale))
            }
            if message.role == .user {
                TextBubble(message.text)
            } else {
                answer
            }
        }
        .padding(.horizontal, FigmaSize.spacingLarge.scaledToArtwork)
        .padding(.vertical, FigmaSize.spacingMedium.scaledToArtwork)
    }

    private var answer: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacingLarge.scaledToArtwork) {
            if !message.text.isEmpty {
                RichText(message.text, onOpenLink: handlers.openLink)
            }
            AnswerBlocksView(message: message, handlers: handlers)
            if let status = message.status {
                StatusIndicator(status)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Aksi dari baris ke view model; closure agar baris tetap value type yang ringan.
struct MessageHandlers {
    let perform: (ActionTarget, String) -> Void
    let select: (OptionsBlock.Item, Int, String) -> Void
    let openLink: (URL) -> Void
}

/// Isi cell daftar. Cell UIKit tidak mewarisi environment SwiftUI, jadi locale dan palette
/// dipasang ulang di sini.
struct MessageRowContent: View {
    let message: ChatMessage
    let handlers: MessageHandlers
    let locale: Locale
    let colors: any FigmaColorProtocol

    var body: some View {
        MessageRow(message: message, handlers: handlers)
            .environment(\.locale, locale)
            .designColors(colors)
    }
}
