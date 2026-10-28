//
//  WireMessage.swift
//  TanyaAI
//
//  Created by Wendra on 28/10/26.
//

/// Objek `Message` gateway (§4), sama persis di history dan event SSE `message`.
/// `payload` dibaca sebagai teks; payload objek (tipe selain `text`) menjadi nil dan belum dirender.
struct WireMessage: Decodable {
    let messageId: String
    let seq: String
    let direction: ChatAuthor
    let payload: String?
    let status: ChatMessageStatus
    /// ISO 8601 dengan zona waktu, mis. `2026-10-23T15:00:00+07:00`.
    let createdAt: String?

    private enum CodingKeys: CodingKey {
        case messageId, seq, direction, payload, status, createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messageId = try container.decode(String.self, forKey: .messageId)
        seq = try container.decode(String.self, forKey: .seq)
        direction = try container.decode(ChatAuthor.self, forKey: .direction)
        payload = try? container.decodeIfPresent(String.self, forKey: .payload)
        status = try container.decode(ChatMessageStatus.self, forKey: .status)
        createdAt = try? container.decodeIfPresent(String.self, forKey: .createdAt)
    }
}
