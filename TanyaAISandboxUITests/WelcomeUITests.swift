//
//  WelcomeUITests.swift
//  TanyaAISandboxUITests
//
//  Created by Wendra on 27/10/26.
//

import XCTest

final class WelcomeUITests: XCTestCase {
    private let application = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testWelcomeShowsBackendGreetingAndShortcutsInOrder() {
        launch(locale: "id")
        XCTAssertTrue(application.staticTexts["Hi, Lara Croft!"].waitForExistence(timeout: 10))
        XCTAssertTrue(application.staticTexts["Mulai dari sini:"].exists)
        let shortcuts = (0..<3).map { application.buttons["welcome.shortcut.\($0)"] }
        XCTAssertTrue(shortcuts.allSatisfy(\.exists))
        XCTAssertTrue(shortcuts[0].label.contains("Cek Portfolio"))
        XCTAssertTrue(shortcuts[2].label.contains("Ajukan Surat Referensi"))
        XCTAssertLessThan(shortcuts[0].frame.maxY, shortcuts[1].frame.minY)
        XCTAssertLessThan(shortcuts[1].frame.maxY, shortcuts[2].frame.minY)
        XCTAssertFalse(application.buttons["header.scrolled"].exists)
        capture("welcome-id")
    }

    /// Pertanyaan pertama dari stream menggantikan sambutan; percakapan baru mengembalikannya.
    func testShortcutTurnsSendIntoLoadingUntilNewConversation() {
        launch(locale: "en", extra: ["--hold-reply"])
        let shortcut = application.buttons["welcome.shortcut.0"]
        XCTAssertTrue(shortcut.waitForExistence(timeout: 10))
        let send = application.buttons["composer.send"]
        XCTAssertEqual(send.label, "Send message")
        shortcut.tap()
        XCTAssertEqual(send.label, "Waiting for reply")
        XCTAssertFalse(send.isEnabled)
        XCTAssertTrue(application.descendants(matching: .any)["chat.message.customer"].waitForExistence(timeout: 5))
        XCTAssertFalse(application.otherElements["chat.welcome"].exists)
        let input = application.textViews["composer.input"]
        input.tap()
        input.typeText("Next question")
        XCTAssertFalse(send.isEnabled, "satu pertanyaan per waktu: kirim tetap nonaktif selama menunggu")
        capture("welcome-awaiting-reply")
        startNewConversation()
        XCTAssertEqual(send.label, "Send message")
        XCTAssertTrue(send.isEnabled)
        XCTAssertTrue(shortcut.waitForExistence(timeout: 5))
        XCTAssertTrue(shortcut.isEnabled)
    }

    /// History tidak kosong: tanpa sambutan, chip tanggal di atas pesan pertama setiap hari.
    func testHistoryReplacesTheWelcomeWithDatedMessages() {
        launch(locale: "id", extra: ["--with-history"])
        let dates = application.descendants(matching: .any).matching(identifier: "chat.date")
        XCTAssertTrue(dates.firstMatch.waitForExistence(timeout: 10))
        XCTAssertFalse(application.buttons["welcome.shortcut.0"].exists)
        XCTAssertFalse(application.descendants(matching: .any)["chat.loading"].exists)
        XCTAssertEqual(dates.count, 2)
        XCTAssertEqual(dates.element(boundBy: 0).label, "14 Okt 2026")
        let first = application.descendants(matching: .any)["chat.message.customer"].firstMatch
        XCTAssertLessThan(dates.element(boundBy: 0).frame.maxY, first.frame.minY)
        capture("chat-history-dates")
    }

    /// Ikon gagal diunduh: kartu tetap tampil dengan ikon fallback FE dan tetap bisa diketuk.
    func testBrokenIconsKeepShortcutsTappable() {
        launch(locale: "id", extra: ["--broken-icons", "--hold-reply"])
        let shortcut = application.buttons["welcome.shortcut.1"]
        XCTAssertTrue(shortcut.waitForExistence(timeout: 10))
        XCTAssertTrue(shortcut.label.contains("Beli Valas"))
        capture("welcome-broken-icons")
        shortcut.tap()
        XCTAssertEqual(application.buttons["composer.send"].label, "Menunggu jawaban")
    }

    /// Ikon belum selesai diunduh: kotak ikon menampilkan spinner, kartu sudah bisa diketuk.
    func testLoadingIconsKeepShortcutsTappable() {
        launch(locale: "id", extra: ["--slow-icons", "--hold-reply"])
        let shortcut = application.buttons["welcome.shortcut.0"]
        XCTAssertTrue(shortcut.waitForExistence(timeout: 10))
        XCTAssertTrue(application.activityIndicators.firstMatch.waitForExistence(timeout: 5))
        capture("welcome-loading-icons")
        shortcut.tap()
        XCTAssertEqual(application.buttons["composer.send"].label, "Menunggu jawaban")
    }

    /// Pertanyaan tampil dari stream (bukan langsung saat dikirim), lalu jawaban bot; `turn_end` membuka kirim lagi.
    func testQuestionAndReplyArriveFromTheStream() {
        launch(locale: "en")
        let shortcut = application.buttons["welcome.shortcut.0"]
        XCTAssertTrue(shortcut.waitForExistence(timeout: 10))
        shortcut.tap()
        let question = application.descendants(matching: .any)["chat.message.customer"].firstMatch
        XCTAssertTrue(question.waitForExistence(timeout: 5))
        XCTAssertEqual(question.label, "Cek Portfolio saya")
        let reply = application.descendants(matching: .any)["chat.message.reply"].firstMatch
        XCTAssertTrue(reply.waitForExistence(timeout: 5))
        XCTAssertLessThan(question.frame.maxY, reply.frame.minY)
        let send = application.buttons["composer.send"]
        let unlocked = expectation(for: NSPredicate(format: "label == %@", "Send message"), evaluatedWith: send)
        wait(for: [unlocked], timeout: 5)
        capture("chat-question-and-reply")
    }

    private func launch(locale: String, extra: [String] = []) {
        application.launchArguments = ["--language", locale] + extra
        application.launch()
        let open = application.buttons["sandbox.open"]
        XCTAssertTrue(open.waitForExistence(timeout: 10))
        open.tap()
    }

    private func startNewConversation() {
        application.buttons["chat.more"].tap()
        let item = application.buttons["New conversation"]
        XCTAssertTrue(item.waitForExistence(timeout: 5))
        item.tap()
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: application.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
