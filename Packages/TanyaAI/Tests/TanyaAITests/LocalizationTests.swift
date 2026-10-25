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
            #expect(String(resource: TanyaAI.R.string.localizable.chatSend, locale: locale) == expected)
            let placeholder = String(resource: TanyaAI.R.string.localizable.chatPlaceholder, locale: locale)
            #expect(!placeholder.isEmpty)
            #expect(placeholder != "chat.placeholder")
        }
        for (identifier, expected) in [("en", "Back"), ("id", "Kembali"), ("zh-Hans", "返回")] {
            let locale = Locale(identifier: identifier)
            #expect(String(resource: TanyaAI.R.string.localizable.chatBack, locale: locale) == expected)
            #expect(String(resource: TanyaAI.R.string.localizable.chatTitle, locale: locale) == "Tanya AI")
        }
    }

    @Test
    func unsupportedLanguageFallsBackToEnglish() {
        #expect(
            String(resource: TanyaAI.R.string.localizable.chatSend, locale: Locale(identifier: "fr_FR"))
                == "Send message"
        )
    }
}
