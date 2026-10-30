//
//  TanyaAIInitResponseTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 28/10/26.
//

import Foundation
import TanyaAI
import Testing

@testable import Tanya_AI_Sandbox

/// Kontrak `data` inquiry init di sisi host: decode JSON BE lalu petakan ke `WelcomeContent` TanyaAI.
struct TanyaAIInitResponseTests {
    @Test
    func mapsGreetingAndShortcutsInOrderAndIgnoresHostFields() throws {
        let welcome = try decode(
            """
            { "data": {
              "isTncAgreed": true, "tncCode": "TANYA_AI",
              "shortcuts": [
                { "title": "Cek Portfolio", "description": "Pantau aset & performa investasimu",
                  "iconUrl": "https://example.com/portfolio.png", "prompt": "Cek Portfolio saya" },
                { "title": "Beli Valas", "description": "Cek kurs dan beli mata uang asing",
                  "iconUrl": "https://example.com/valas.png", "prompt": "Saya mau beli valas" }
              ],
              "greetings": { "title": "Hi, Lara Croft!", "description": "Temukan insight finansial" }
            } }
            """
        )
        #expect(
            welcome.greetings == WelcomeGreeting(title: "Hi, Lara Croft!", description: "Temukan insight finansial"))
        #expect(welcome.shortcuts.map(\.title) == ["Cek Portfolio", "Beli Valas"])
        #expect(welcome.shortcuts.first?.iconURL == URL(string: "https://example.com/portfolio.png"))
        #expect(welcome.shortcuts.last?.prompt == "Saya mau beli valas")
    }

    @Test(arguments: [#""iconUrl": "","#, #""iconUrl": null,"#, ""])
    func emptyOrMissingIconURLKeepsTheShortcut(iconField: String) throws {
        let welcome = try decode(
            """
            { "data": {
              "shortcuts": [ { "title": "A", "description": "B", \(iconField) "prompt": "C" } ],
              "greetings": { "title": "Hi", "description": "D" } } }
            """
        )
        let shortcut = try #require(welcome.shortcuts.first)
        #expect(shortcut.iconURL == nil)
        #expect(shortcut.prompt == "C")
    }

    /// Apib awal menulis `descripton`; BE diminta memperbaiki ke `description`, jadi typo tidak diterima.
    @Test
    func misspelledDescriptionKeyIsRejected() {
        #expect(throws: DecodingError.self) {
            try decode(
                """
                { "data": {
                  "shortcuts": [ { "title": "A", "descripton": "B", "iconUrl": "", "prompt": "C" } ],
                  "greetings": { "title": "Hi", "description": "D" } } }
                """
            )
        }
    }
}

// MARK: - Helpers

private extension TanyaAIInitResponseTests {
    func decode(_ json: String) throws -> WelcomeContent {
        let initData = try JSONDecoder().decode(TanyaAIInitResponse.self, from: Data(json.utf8)).data
        return WelcomeContent(greetings: initData.greetings.greeting, shortcuts: initData.shortcuts.map(\.shortcut))
    }
}
