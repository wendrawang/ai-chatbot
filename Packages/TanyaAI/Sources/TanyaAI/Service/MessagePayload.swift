//
//  MessagePayload.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

import Foundation

/// Satu pesan dari history atau stream.
struct MessagePayload: Decodable {
    let id: String
    let role: ChatRole
    let text: String
    /// Untuk jawaban bot: id chat user yang dijawab.
    let replyTo: String?
    let createdAt: Date
}
