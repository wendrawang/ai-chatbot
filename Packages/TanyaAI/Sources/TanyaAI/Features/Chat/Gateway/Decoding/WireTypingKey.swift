//
//  WireTypingKey.swift
//  TanyaAI
//
//  Created by Wendra on 12/11/26.
//

/// Key `data` event `typing` yang dibaca `WireTyping`.
enum WireTypingKey: String, CodingKey {
    case direction
    case isTyping = "typing"
    // Decoder `.wire` mengubah `ttl_s` menjadi `ttlS` sebelum dicocokkan.
    case lifetimeSeconds = "ttlS"
}
