//
//  MessagesSection.swift
//  TanyaAI
//
//  Created by Wendra on 28/10/26.
//

import DesignKit
import SwiftUI

/// Daftar pesan teks sementara di area scroll `ScreenContainer`, kronologis di bawah sambutan.
/// Pesan tanpa teks (payload non-teks) belum dirender.
/// TODO: Ganti dengan list ber-recycle (UITableView) beserta anchor scroll sesuai `REVAMP_NOTES`.
@MainActor
struct MessagesSection: View {
    private let messages: [ChatMessage]

    init(messages: [ChatMessage]) {
        self.messages = messages
    }

    var body: some View {
        LazyVStack(spacing: FigmaSize.spacingLarge.scaledToArtwork) {
            ForEach(messages) { message in
                if let text = message.text {
                    MessageBubble(text: text, isOutgoing: message.author == .customer)
                        .accessibilityIdentifier(identifier(of: message))
                }
            }
        }
        .padding(.top, messages.isEmpty ? .zero : FigmaSize.spacingExtraLarge.scaledToArtwork)
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
