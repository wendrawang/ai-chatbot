//
//  LocalizationTests.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import DesignKit
import XCTest

@testable import TanyaAI

final class LocalizationTests: XCTestCase {
    func testAllSupportedLanguagesHaveTranslatedLabels() {
        let cases = [("en", "Send message"), ("id", "Kirim pesan"), ("zh-Hans", "发送消息"), ("zh_CN", "发送消息")]
        for (identifier, expected) in cases {
            let locale = Locale(identifier: identifier)
            XCTAssertEqual(String(resource: TanyaAI.R.string.localizable.chatSend, locale: locale), expected)
            let placeholder = String(resource: TanyaAI.R.string.localizable.chatPlaceholder, locale: locale)
            XCTAssertFalse(placeholder.isEmpty)
            XCTAssertNotEqual(placeholder, "chat.placeholder")
        }
        for (identifier, expected) in [("en", "Back"), ("id", "Kembali"), ("zh-Hans", "返回")] {
            let locale = Locale(identifier: identifier)
            XCTAssertEqual(String(resource: TanyaAI.R.string.localizable.chatBack, locale: locale), expected)
            XCTAssertEqual(String(resource: TanyaAI.R.string.localizable.chatTitle, locale: locale), "Tanya AI")
        }
    }

    func testUnsupportedLanguageFallsBackToEnglish() {
        XCTAssertEqual(
            String(resource: TanyaAI.R.string.localizable.chatSend, locale: Locale(identifier: "fr_FR")), "Send message"
        )
    }
}
