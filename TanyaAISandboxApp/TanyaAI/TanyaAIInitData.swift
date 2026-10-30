//
//  TanyaAIInitData.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 28/10/26.
//

import Foundation
import TanyaAI

/// Objek `data` inquiry init milik host. `isTncAgreed`/`tncCode` belum dipakai sandbox.
struct TanyaAIInitData: Decodable {
    let greetings: TanyaAIInitGreeting
    let shortcuts: [TanyaAIInitShortcut]

    /// Dipetakan ke model TanyaAI; package tidak mengenal bentuk JSON init.
    var welcome: WelcomeContent {
        WelcomeContent(greetings: greetings.greeting, shortcuts: shortcuts.map(\.shortcut))
    }

    /// Sandbox: isi tetap dari BE, hanya URL ikon setiap shortcut yang diganti.
    func replacingIcons(with iconURL: URL) -> TanyaAIInitData {
        let shortcuts = shortcuts.map {
            TanyaAIInitShortcut(
                title: $0.title, description: $0.description, iconUrl: iconURL.absoluteString, prompt: $0.prompt
            )
        }
        return TanyaAIInitData(greetings: greetings, shortcuts: shortcuts)
    }
}
