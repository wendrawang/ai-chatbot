//
//  ChatMessage.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

import Foundation

/// Satu baris percakapan. Value type agar daftar hanya me-render ulang baris yang berubah.
struct ChatMessage: Identifiable, Equatable {
    enum Role: Equatable {
        case user, assistant
    }

    /// Status kirim chat user; pesan dari BE selalu `sent`.
    enum Delivery: Equatable {
        case sending, sent, failed
    }

    let id: String
    let role: Role
    let text: String
    let createdAt: Date
    let replyTo: String?
    var delivery = Delivery.sent
}

extension ChatMessage {
    init(_ payload: MessagePayload) {
        self.init(
            id: payload.id, role: payload.role == .user ? .user : .assistant, text: payload.text,
            createdAt: payload.createdAt, replyTo: payload.replyTo
        )
    }

    /// Chat user yang belum punya id dari BE.
    static func pendingQuestion(_ text: String) -> ChatMessage {
        ChatMessage(
            id: UUID().uuidString, role: .user, text: text, createdAt: Date(), replyTo: nil, delivery: .sending
        )
    }
}
