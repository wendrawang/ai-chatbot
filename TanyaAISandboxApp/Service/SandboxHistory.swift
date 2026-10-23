//
//  SandboxHistory.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 22/10/26.
//

import Foundation

/// Satu halaman history, urut dari terlama ke terbaru. Nama key JSON adalah metadata kontrak.
struct SandboxHistory: Encodable {
    enum CodingKeys: String, CodingKey {
        case messages
        case isMoreAvailable = "hasMore"
    }

    let messages: [SandboxMessage]
    let isMoreAvailable: Bool
}
