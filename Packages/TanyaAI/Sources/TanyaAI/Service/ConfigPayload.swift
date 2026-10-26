//
//  ConfigPayload.swift
//  TanyaAI
//
//  Created by Wendra on 27/10/26.
//

/// Body get config: greeting dan shortcut untuk percakapan kosong.
struct ConfigPayload: Decodable {
    let greeting: String
    let shortcuts: [ShortcutPayload]?
}
