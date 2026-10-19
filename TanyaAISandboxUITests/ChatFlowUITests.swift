//
//  ChatFlowUITests.swift
//  TanyaAISandboxUITests
//
//  Created by Wendra on 19/10/26.
//

import XCTest

/// Alur chat dengan service dummy sandbox (fixture SSE + inquiry).
final class ChatFlowUITests: XCTestCase {
    private let application = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testWelcomeShortcutRunsThePortfolioIntentIntoATable() {
        launch(locale: "en")
        XCTAssertTrue(application.staticTexts["Hi, Lara Croft!"].waitForExistence(timeout: 10))
        XCTAssertTrue(application.staticTexts["Start here:"].exists)
        let shortcuts = application.buttons.matching(identifier: "quickAction.row")
        XCTAssertEqual(shortcuts.count, 3)
        capture("chat-welcome")
        shortcuts.element(boundBy: .zero).tap()
        XCTAssertTrue(application.descendants(matching: .any)["bubble.user"].waitForExistence(timeout: 5))
        XCTAssertTrue(application.otherElements["table"].waitForExistence(timeout: 10))
        XCTAssertTrue(application.staticTexts["+3,600,000"].exists)
        capture("chat-portfolio-table")
    }

    func testFreeTextShowsMarkupLinksAndReadOnlyOptions() {
        launch(locale: "id")
        send("halo")
        XCTAssertTrue(application.links["BISA DIKLIK"].waitForExistence(timeout: 10))
        waitForAnswer(in: application)
        capture("chat-free-text")
        let option = application.buttons["#1 lorem ipsum options - here"]
        XCTAssertTrue(option.isEnabled)
        option.tap()
        waitForAnswer(in: application)
        XCTAssertFalse(application.buttons["#1 lorem ipsum options - here"].firstMatch.isEnabled)
        application.links["BISA DIKLIK"].firstMatch.tap()
        XCTAssertTrue(application.navigationBars["google.com"].waitForExistence(timeout: 5))
    }

    func testStopEndsTheAnswerAndKeepsTheConversation() {
        launch(locale: "en")
        send("hello")
        let stop = application.buttons["composer.stop"]
        XCTAssertTrue(stop.waitForExistence(timeout: 5))
        stop.tap()
        // Jawaban berhenti: tombol kirim kembali dan status loading hilang.
        XCTAssertTrue(application.buttons["composer.send"].waitForExistence(timeout: 5))
        XCTAssertFalse(stop.exists)
        XCTAssertFalse(application.descendants(matching: .any)["status.indicator"].exists)
    }

    private func launch(locale: String) {
        application.launchArguments = ["--language", locale]
        application.launch()
        let open = application.buttons["sandbox.open"]
        XCTAssertTrue(open.waitForExistence(timeout: 10))
        open.tap()
    }

    private func send(_ text: String) {
        let input = application.textViews["composer.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        input.tap()
        input.typeText(text)
        application.buttons["composer.send"].tap()
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: application.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

/// Tunggu jawaban selesai: tombol stop hilang dan tombol kirim kembali.
func waitForAnswer(in application: XCUIApplication, timeout: TimeInterval = 15) {
    let stop = application.buttons["composer.stop"]
    let gone = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: stop)
    XCTAssertEqual(XCTWaiter.wait(for: [gone], timeout: timeout), .completed)
    XCTAssertTrue(application.buttons["composer.send"].waitForExistence(timeout: timeout))
}
