//
//  SandboxMessage.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 22/10/26.
//

import Foundation

/// Pesan dalam bentuk JSON kontrak (`docs/CHAT_CONTRACT.md`), sebagaimana dikirim BE.
struct SandboxMessage: Codable {
    enum Role: String, Codable {
        case user, assistant
    }

    let id: String
    let role: Role
    let text: String
    let replyTo: String?
    let createdAt: Date

    init(role: Role, text: String, replyTo: String? = nil, createdAt: Date = Date()) {
        id = UUID().uuidString
        self.role = role
        self.text = text
        self.replyTo = replyTo
        self.createdAt = createdAt
    }
}
