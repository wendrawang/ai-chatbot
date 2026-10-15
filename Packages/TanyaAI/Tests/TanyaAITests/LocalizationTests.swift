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
    }

    func testUnsupportedLanguageFallsBackToEnglish() {
        XCTAssertEqual(ChatCopy.send.text(locale: Locale(identifier: "fr_FR")), "Send message")
    }
}
