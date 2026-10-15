//
//  LocalizationTests.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import XCTest

@testable import TanyaAI

final class LocalizationTests: XCTestCase {
    func testAllSupportedLanguagesHaveTranslatedLabels() {
        let cases = [("en", "Send message"), ("id", "Kirim pesan"), ("zh-Hans", "发送消息"), ("zh_CN", "发送消息")]
        for (identifier, expected) in cases {
            XCTAssertEqual(ChatCopy.send.text(locale: Locale(identifier: identifier)), expected)
            XCTAssertFalse(ChatCopy.placeholder.text(locale: Locale(identifier: identifier)).isEmpty)
            XCTAssertNotEqual(ChatCopy.placeholder.text(locale: Locale(identifier: identifier)), "chat.placeholder")
        }
        for (identifier, expected) in [("en", "Back"), ("id", "Kembali"), ("zh-Hans", "返回")] {
            XCTAssertEqual(ChatCopy.back.text(locale: Locale(identifier: identifier)), expected)
            XCTAssertEqual(ChatCopy.title.text(locale: Locale(identifier: identifier)), "Tanya AI")
        }
    }

    func testUnsupportedLanguageFallsBackToEnglish() {
        XCTAssertEqual(ChatCopy.send.text(locale: Locale(identifier: "fr_FR")), "Send message")
    }
}
