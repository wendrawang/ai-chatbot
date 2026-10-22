//
//  ChatPayload.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

import Foundation

// Body JSON dari host, sesuai `docs/CHAT_CONTRACT.md`. Hanya dipakai untuk decode.
// Nama key JSON adalah metadata kontrak, jadi boleh ditulis langsung di file ini.

struct SessionPayload: Decodable {
    let sessionId: String
}

struct HistoryPayload: Decodable {
    enum CodingKeys: String, CodingKey {
        case messages
        case isMoreAvailable = "hasMore"
    }

    /// Urut dari terlama ke terbaru.
    let messages: [MessagePayload]
    let isMoreAvailable: Bool
}

struct MessagePayload: Decodable {
    enum Role: String, Decodable {
        case user, assistant
    }

    let id: String
    let role: Role
    let text: String
    /// Untuk jawaban bot: id chat user yang dijawab.
    let replyTo: String?
    let createdAt: Date
}

/// Nama event SSE yang dikenali; event lain diabaikan.
enum ServerEventName: String {
    case message, heartbeat, error
}

enum ChatPayload {
    static func decode<Payload: Decodable>(_ type: Payload.Type, from data: Data) throws -> Payload {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: data)
    }
}
