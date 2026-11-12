//
//  WireTyping.swift
//  TanyaAI
//
//  Created by Wendra on 10/11/26.
//

import Foundation

/// `data` event SSE `typing` (contract §5): sinyal sementara, tidak tersimpan dan tidak di-replay.
struct WireTyping: Decodable {
    let direction: ChatAuthor
    let isTyping: Bool
    /// Batas tampil indikator bila tidak ada kabar baru (`ttl_s`).
    let lifetimeSeconds: TimeInterval?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: WireTypingKey.self)
        direction = try container.decode(ChatAuthor.self, forKey: .direction)
        isTyping = try container.decode(Bool.self, forKey: .isTyping)
        lifetimeSeconds = try container.decodeIfPresent(TimeInterval.self, forKey: .lifetimeSeconds)
    }
}
