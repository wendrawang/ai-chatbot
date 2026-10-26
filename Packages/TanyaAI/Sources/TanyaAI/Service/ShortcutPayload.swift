//
//  ShortcutPayload.swift
//  TanyaAI
//
//  Created by Wendra on 27/10/26.
//

/// Satu shortcut dari config.
struct ShortcutPayload: Decodable {
    let id: String
    let label: String
    /// Teks yang dikirim sebagai chat; bila kosong memakai `label`.
    let message: String?
}
