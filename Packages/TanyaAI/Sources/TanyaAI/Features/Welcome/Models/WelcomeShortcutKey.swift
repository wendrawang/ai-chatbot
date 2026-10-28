//
//  WelcomeShortcutKey.swift
//  TanyaAI
//
//  Created by Wendra on 27/10/26.
//

/// Key JSON `shortcuts[]` sesuai kontrak BE. Nama case sama dengan key, jadi tidak perlu raw value.
enum WelcomeShortcutKey: String, CodingKey {
    case title
    case description
    case iconUrl
    case prompt
}
