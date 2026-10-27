//
//  HistoryPayloadKey.swift
//  TanyaAI
//
//  Created by Wendra on 27/10/26.
//

/// Key JSON `HistoryPayload`. Nama key adalah metadata kontrak.
enum HistoryPayloadKey: String, CodingKey {
    case messages, hasMore
}
