//
//  SandboxHistory.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 22/10/26.
//

import Foundation

/// Satu halaman history, urut dari terlama ke terbaru.
struct SandboxHistory: Encodable {
    let messages: [SandboxMessage]
    let isMoreAvailable: Bool

    // `isMoreAvailable` ditulis sebagai key JSON `hasMore`.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SandboxHistoryKey.self)
        try container.encode(messages, forKey: .messages)
        try container.encode(isMoreAvailable, forKey: .hasMore)
    }
}
