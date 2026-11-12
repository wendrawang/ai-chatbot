//
//  WireCancel.swift
//  TanyaAI
//
//  Created by Wendra on 30/10/26.
//

/// `data` 200 `POST /v1/chat/conversations/{id}/cancel`. True = turn yang berjalan dibatalkan; pembuka kunci
/// tetap `turn_end {"status":"canceled"}` di stream. False = tidak ada turn aktif (no-op).
struct WireCancel: Decodable {
    let isCanceled: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: WireCancelKey.self)
        isCanceled = try container.decode(Bool.self, forKey: .isCanceled)
    }
}
