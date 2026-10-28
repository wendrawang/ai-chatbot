//
//  MessagesSection.swift
//  TanyaAI
//
//  Created by Wendra on 28/10/26.
//

import DesignKit
import SwiftUI

/// Daftar pesan teks sementara di area scroll `ScreenContainer`, kronologis, dengan chip tanggal di atas
/// pesan pertama setiap hari. Pesan tanpa teks (payload non-teks) belum dirender.
/// TODO: Ganti dengan list ber-recycle (UITableView) beserta anchor scroll sesuai `REVAMP_NOTES`.
@MainActor
struct MessagesSection: View {
    @Environment(\.locale)
    private var locale
    private let days: [ChatDay]

    init(messages: [ChatMessage]) {
        days = messages.groupedByDay()
    }

    var body: some View {
        LazyVStack(spacing: FigmaSize.spacingLarge.scaledToArtwork) {
            ForEach(days) { day in
                if let date = day.date {
                    DateChip(text: ChatDateFormat.dayLabel(for: date, locale: locale))
                        .accessibilityIdentifier(ChatElementIdentifier.date)
                }
                ForEach(day.messages) { message in
                    if let text = message.text {
                        MessageBubble(text: text, isOutgoing: message.author == .customer)
                            .accessibilityIdentifier(identifier(of: message))
                    }
                }
            }
        }
        .padding(.top, days.isEmpty ? .zero : FigmaSize.spacingLarge.scaledToArtwork)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(ChatElementIdentifier.messages)
    }
}

// MARK: - Helpers

private extension MessagesSection {
    func identifier(of message: ChatMessage) -> String {
        message.author == .customer ? ChatElementIdentifier.customerMessage : ChatElementIdentifier.replyMessage
    }
}
