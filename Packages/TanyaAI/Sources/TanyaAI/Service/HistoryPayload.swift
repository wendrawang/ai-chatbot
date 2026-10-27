//
//  HistoryPayload.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

/// Satu halaman history, urut dari terlama ke terbaru.
struct HistoryPayload: Decodable {
    let messages: [MessagePayload]
    let isMoreAvailable: Bool

    // Key JSON `hasMore` dibaca ke `isMoreAvailable` agar Bool tetap berawalan `is`.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: HistoryPayloadKey.self)
        messages = try container.decode([MessagePayload].self, forKey: .messages)
        isMoreAvailable = try container.decode(Bool.self, forKey: .hasMore)
    }
}
