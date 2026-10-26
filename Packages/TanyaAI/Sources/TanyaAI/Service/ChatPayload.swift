//
//  ChatPayload.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

import Foundation

/// Decode body JSON dari host sesuai `docs/CHAT_CONTRACT.md`.
enum ChatPayload {
    static func decode<Payload: Decodable>(_ type: Payload.Type, from data: Data) throws -> Payload {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: data)
    }
}
