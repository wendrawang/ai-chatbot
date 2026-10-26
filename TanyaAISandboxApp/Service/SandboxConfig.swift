//
//  SandboxConfig.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 26/10/26.
//

import Foundation

/// Body get config: greeting dan shortcut untuk percakapan kosong.
struct SandboxConfig: Encodable {
    struct Shortcut: Codable {
        let id: String
        let label: String
        let message: String?
    }

    let greeting: String
    let shortcuts: [Shortcut]
}
