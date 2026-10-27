//
//  WelcomeContentTests.swift
//  TanyaAI
//
//  Created by Wendra on 27/10/26.
//

import Foundation
import Testing

@testable import TanyaAI

/// Kontrak `data` inquiry init Tanya AI. Host men-decode objek `data` langsung ke `WelcomeContent`.
struct WelcomeContentTests {
    @Test
    func decodesGreetingAndShortcutsInOrderAndIgnoresHostFields() throws {
        let content = try decode(
            """
            {
              "isTncAgreed": true, "tncCode": "TANYA_AI",
              "shortcuts": [
                { "title": "Cek Portfolio", "description": "Pantau aset & performa investasimu",
                  "iconUrl": "https://example.com/portfolio.png", "prompt": "Cek Portfolio saya" },
                { "title": "Beli Valas", "description": "Cek kurs dan beli mata uang asing",
                  "iconUrl": "https://example.com/valas.png", "prompt": "Saya mau beli valas" }
              ],
              "greetings": { "title": "Hi, Lara Croft!", "description": "Temukan insight finansial" }
            }
            """
        )
        #expect(
            content.greetings == WelcomeGreeting(title: "Hi, Lara Croft!", description: "Temukan insight finansial"))
        #expect(content.shortcuts.map(\.title) == ["Cek Portfolio", "Beli Valas"])
        #expect(content.shortcuts.first?.iconURL == URL(string: "https://example.com/portfolio.png"))
        #expect(content.shortcuts.last?.prompt == "Saya mau beli valas")
    }

    @Test(arguments: [#""iconUrl": "","#, #""iconUrl": null,"#, ""])
    func emptyOrMissingIconURLKeepsTheShortcut(iconField: String) throws {
        let content = try decode(
            """
            { "shortcuts": [ { "title": "A", "description": "B", \(iconField) "prompt": "C" } ],
              "greetings": { "title": "Hi", "description": "D" } }
            """
        )
        let shortcut = try #require(content.shortcuts.first)
        #expect(shortcut.iconURL == nil)
        #expect(shortcut.prompt == "C")
    }

    /// Apib awal menulis `descripton`; BE diminta memperbaiki ke `description`, jadi typo tidak diterima.
    @Test
    func misspelledDescriptionKeyIsRejected() {
        #expect(throws: DecodingError.self) {
            try decode(
                """
                { "shortcuts": [ { "title": "A", "descripton": "B", "iconUrl": "", "prompt": "C" } ],
                  "greetings": { "title": "Hi", "description": "D" } }
                """
            )
        }
    }
}

// MARK: - Helpers

private extension WelcomeContentTests {
    func decode(_ json: String) throws -> WelcomeContent {
        try JSONDecoder().decode(WelcomeContent.self, from: Data(json.utf8))
    }
}
