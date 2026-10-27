//
//  ChatFlowUITests.swift
//  TanyaAISandboxUITests
//
//  Created by Wendra on 26/10/26.
//

import XCTest

/// T&C host, greeting dan shortcut, chat yang tampil lewat stream, serta tombol stop.
final class ChatFlowUITests: XCTestCase {
    private let application = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testTermsShowOnceThenChatOpensDirectly() {
        launch(extra: ["--reset-terms"])
        let accept = application.buttons["sandbox.terms.accept"]
        XCTAssertTrue(accept.waitForExistence(timeout: 10))
        XCTAssertFalse(application.textViews["composer.input"].exists)
        capture("terms")
        accept.tap()
        let input = application.textViews["composer.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        application.buttons["header.back"].tap()
        let open = application.buttons["sandbox.open"]
        XCTAssertTrue(open.waitForExistence(timeout: 5))
        open.tap()
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        XCTAssertFalse(accept.exists)
    }

    func testShortcutIsSentAndAnsweredThroughTheStream() {
        launch(extra: ["--terms-accepted"])
        let shortcuts = application.buttons.matching(identifier: "suggestion")
        XCTAssertTrue(shortcuts.firstMatch.waitForExistence(timeout: 10))
        capture("chat-welcome")
        shortcuts.firstMatch.tap()
        let questions = application.staticTexts.matching(identifier: "chat.question")
        XCTAssertTrue(
            questions.element(matching: NSPredicate(format: "label == %@", "Berapa saldo saya?"))
                .waitForExistence(timeout: 5))
        XCTAssertFalse(shortcuts.firstMatch.exists, "shortcut hanya untuk percakapan kosong")
        XCTAssertTrue(
            application.staticTexts.matching(identifier: "chat.answer").firstMatch.waitForExistence(timeout: 10))
        XCTAssertTrue(application.buttons["composer.send"].waitForExistence(timeout: 5))
        capture("chat-answered")
    }

    func testStopEndsTheAnswerAndTheComposerIsReadyAgain() {
        launch(extra: ["--terms-accepted", "--slow-reply"])
        let input = application.textViews["composer.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        input.tap()
        input.typeText("Promo")
        application.buttons["composer.send"].tap()
        // Mengirim: titik bergerak di tombol, draft tetap sampai pesan datang dari stream.
        XCTAssertTrue(application.otherElements["composer.sending"].waitForExistence(timeout: 2))
        XCTAssertEqual(input.value as? String, "Promo")
        capture("chat-sending")
        let stop = application.buttons["composer.stop"]
        XCTAssertTrue(stop.waitForExistence(timeout: 5))
        // Menunggu jawaban: pesan user tampil, titik di daftar, tombol stop.
        XCTAssertTrue(application.otherElements["chat.replying"].waitForExistence(timeout: 2))
        capture("chat-waiting")
        XCTAssertEqual(stop.label, "Hentikan jawaban")
        XCTAssertEqual(input.value as? String, "")
        stop.tap()
        XCTAssertTrue(application.staticTexts["chat.answerStopped"].waitForExistence(timeout: 5))
        XCTAssertTrue(application.buttons["composer.send"].waitForExistence(timeout: 5))
        XCTAssertFalse(application.staticTexts.matching(identifier: "chat.answer").firstMatch.exists)
        capture("chat-stopped")
    }

    private func launch(extra: [String]) {
        application.launchArguments = ["--language", "id"] + extra
        application.launch()
        let open = application.buttons["sandbox.open"]
        XCTAssertTrue(open.waitForExistence(timeout: 10))
        open.tap()
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: application.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
