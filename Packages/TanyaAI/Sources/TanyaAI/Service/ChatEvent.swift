//
//  ChatEvent.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import Foundation

/// Event SSE yang sudah di-decode. Nama event tak dikenal dilewati.
enum ChatEvent: Equatable {
    case start(messageId: String)
    case status(String)
    case delta(String)
    case intent(TanyaAIIntent)
    case blocks([ChatBlock])
    case end
    case failure(isRetryable: Bool)

    private enum Name: String {
        case start, status, delta, intent, blocks, end, error
    }

    /// Satu bentuk `data` untuk semua event; field yang tidak dipakai event itu boleh tidak ada.
    private struct Payload: Decodable {
        let messageId: String?
        let text: String?
        let delta: String?
        let intent: TanyaAIIntent?
        let blocks: [ChatBlock]?
        let isRetryable: Bool?
    }

    /// Nil untuk event tak dikenal atau `data` yang tidak sesuai kontrak.
    init?(_ event: TanyaAIServerEvent) {
        guard let name = Name(rawValue: event.name),
            let payload = try? JSONDecoder().decode(Payload.self, from: event.data),
            let decoded = Self.event(name, payload)
        else { return nil }
        self = decoded
    }

    /// Nil bila field wajib untuk event itu tidak ada.
    private static func event(_ name: Name, _ payload: Payload) -> ChatEvent? {
        switch name {
        case .start: return .start(messageId: payload.messageId ?? UUID().uuidString)
        case .status: return payload.text.map(ChatEvent.status)
        case .delta: return payload.delta.map(ChatEvent.delta)
        case .intent: return payload.intent.map(ChatEvent.intent)
        case .blocks: return .blocks((payload.blocks ?? []).filter { $0 != .unsupported })
        case .end: return .end
        case .error: return .failure(isRetryable: payload.isRetryable ?? false)
        }
    }
}
