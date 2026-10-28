//
//  TanyaAIInitData.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 28/10/26.
//

import TanyaAI

/// Objek `data` inquiry init milik host. `isTncAgreed`/`tncCode` belum dipakai sandbox.
struct TanyaAIInitData: Decodable {
    let greetings: TanyaAIInitGreeting
    let shortcuts: [TanyaAIInitShortcut]

    /// Dipetakan ke model TanyaAI; package tidak mengenal bentuk JSON init.
    var welcome: WelcomeContent {
        WelcomeContent(greetings: greetings.greeting, shortcuts: shortcuts.map(\.shortcut))
    }
}
