//
//  WelcomeContent.swift
//  TanyaAI
//
//  Created by Wendra on 27/10/26.
//

import Foundation

/// Isi halaman sambutan dari BE (inquiry init Tanya AI, objek `data`). Host men-decode objek itu
/// langsung ke tipe ini; field lain di `data` seperti `isTncAgreed`/`tncCode` milik host dan diabaikan.
public struct WelcomeContent: Decodable, Equatable {
    public let greetings: WelcomeGreeting
    public let shortcuts: [WelcomeShortcut]

    public init(greetings: WelcomeGreeting, shortcuts: [WelcomeShortcut]) {
        self.greetings = greetings
        self.shortcuts = shortcuts
    }
}
