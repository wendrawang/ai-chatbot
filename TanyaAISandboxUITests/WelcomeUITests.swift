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

    /// Pertanyaan pertama dari stream menggantikan sambutan; kirim tetap terkunci selama menunggu jawaban.
    func testShortcutTurnsSendIntoLoadingWhileAwaitingReply() {
        launch(locale: "en", extra: ["--hold-reply"])
        let shortcut = application.buttons["welcome.shortcut.0"]
        XCTAssertTrue(shortcut.waitForExistence(timeout: 10))
        let send = application.buttons["composer.send"]
        XCTAssertEqual(send.label, "Send message")
        shortcut.tap()
        XCTAssertEqual(send.label, "Waiting for reply")
        XCTAssertFalse(send.isEnabled)
        waitUntilGone(application.otherElements["chat.welcome"])
        let input = application.textViews["composer.input"]
        input.tap()
        input.typeText("Next question")
        XCTAssertFalse(send.isEnabled, "satu pertanyaan per waktu: kirim tetap nonaktif selama menunggu")
        capture("welcome-awaiting-reply")
    }

    /// History tidak kosong: loading awal selesai tanpa sambutan (daftar pesan menyusul di PR tampilan pesan).
    func testHistoryHidesTheWelcome() {
        launch(locale: "id", extra: ["--with-history"])
        XCTAssertTrue(application.textViews["composer.input"].waitForExistence(timeout: 10))
        waitUntilGone(application.descendants(matching: .any)["chat.loading"])
        XCTAssertFalse(application.buttons["welcome.shortcut.0"].exists)
        capture("chat-history-without-welcome")
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

    /// Pertanyaan datang dari stream (sambutan hilang), lalu jawaban bot dan `turn_end` membuka kirim lagi.
    func testTurnEndFromTheStreamUnlocksSend() {
        launch(locale: "en")
        let shortcut = application.buttons["welcome.shortcut.0"]
        XCTAssertTrue(shortcut.waitForExistence(timeout: 10))
        shortcut.tap()
        let send = application.buttons["composer.send"]
        XCTAssertEqual(send.label, "Waiting for reply")
        waitUntilGone(application.otherElements["chat.welcome"])
        let unlocked = expectation(for: NSPredicate(format: "label == %@", "Send message"), evaluatedWith: send)
        wait(for: [unlocked], timeout: 5)
    }

    private func launch(locale: String, extra: [String] = []) {
        application.launchArguments = ["--language", locale] + extra
        application.launch()
        let open = application.buttons["sandbox.open"]
        XCTAssertTrue(open.waitForExistence(timeout: 10))
        open.tap()
    }

    private func waitUntilGone(_ element: XCUIElement) {
        let gone = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: element)
        wait(for: [gone], timeout: 5)
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: application.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
