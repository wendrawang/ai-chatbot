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
    let id: String
    let role: ChatRole
    let text: String
    let createdAt: Date
    let replyTo: String?
    /// Untuk chat user: jawabannya dihentikan lewat tombol stop.
    var isAnswerStopped = false
}

extension ChatMessage {
    init(_ payload: MessagePayload) {
        self.init(
            id: payload.id, role: payload.role, text: payload.text, createdAt: payload.createdAt,
            replyTo: payload.replyTo
        )
    }
}
