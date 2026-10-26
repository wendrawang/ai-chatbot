//
//  ChatMessage.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

import Foundation

/// Satu baris percakapan, selalu berasal dari BE (history atau stream).
/// Value type agar daftar hanya me-render ulang baris yang berubah.
struct ChatMessage: Identifiable, Equatable {
    enum Role: Equatable {
        case user, assistant
    }

    let id: String
    let role: Role
    let text: String
    let createdAt: Date
    let replyTo: String?
    /// Untuk chat user: jawabannya dihentikan lewat tombol stop.
    var isAnswerStopped = false
}

extension ChatMessage {
    init(_ payload: MessagePayload) {
        self.init(
            id: payload.id, role: payload.role == .user ? .user : .assistant, text: payload.text,
            createdAt: payload.createdAt, replyTo: payload.replyTo
        )
    }
}
