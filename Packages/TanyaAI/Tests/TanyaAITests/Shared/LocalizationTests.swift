//
//  LocalizationTests.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import DesignKit
import Foundation
import Testing

@testable import TanyaAI

struct LocalizationTests {
    @Test
    func allSupportedLanguagesHaveTranslatedLabels() {
        let cases = [("en", "Send message"), ("id", "Kirim pesan"), ("zh-Hans", "发送消息"), ("zh_CN", "发送消息")]
        for (identifier, expected) in cases {
            let locale = Locale(identifier: identifier)
            #expect(String(ChatCopy.send, locale: locale) == expected)
            let placeholder = String(ChatCopy.placeholder, locale: locale)
            #expect(!placeholder.isEmpty)
            #expect(placeholder != "chat.placeholder")
        }
        for (identifier, expected) in [("en", "Back"), ("id", "Kembali"), ("zh-Hans", "返回")] {
            let locale = Locale(identifier: identifier)
            #expect(String(ChatCopy.back, locale: locale) == expected)
            #expect(String(ChatCopy.title, locale: locale) == "Tanya AI")
        }
    }

    @Test(arguments: [("en", "Start here:", "Waiting for reply"), ("id", "Mulai dari sini:", "Menunggu jawaban")])
    func welcomeAndReplyingCopyFollowTheHostLocale(language: String, title: String, replying: String) {
        let locale = Locale(identifier: language)
        #expect(String(ChatCopy.shortcutsTitle, locale: locale) == title)
        #expect(String(ChatCopy.replying, locale: locale) == replying)
    }

    @Test
    func unsupportedLanguageFallsBackToEnglish() {
        #expect(String(ChatCopy.send, locale: Locale(identifier: "fr_FR")) == "Send message")
    }

    @Test(arguments: ["en", "id", "zh-Hans"])
    func copyKeysMatchTheStringsTableExactly(language: String) throws {
        let path = try #require(
            Bundle.module.path(
                forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: language
            )
        )
        let table = try #require(NSDictionary(contentsOfFile: path) as? [String: String])
        #expect(Set(table.keys) == Set(ChatCopy.allCases.map(\.rawValue)))
        #expect(table.values.allSatisfy { !$0.isEmpty })
    }

    @Test
    func missingKeyReturnsTheKeyItself() {
        let text = String(key: "chat.unknown", bundle: .module, locale: Locale(identifier: "id"))
        #expect(text == "chat.unknown")
    }
}
