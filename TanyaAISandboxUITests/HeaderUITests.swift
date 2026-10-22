//
//  HeaderUITests.swift
//  TanyaAISandboxUITests
//
//  Created by Wendra on 16/10/26.
//

import XCTest

final class HeaderUITests: XCTestCase {
    private let application = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testHeaderBoundaryTracksScrollWithoutMovingHeaderOrComposer() {
        launch(locale: "id", extra: ["--header-demo"])
        let header = application.otherElements["header"]
        XCTAssertTrue(header.waitForExistence(timeout: 10))
        let title = application.staticTexts["header.title"]
        let titleFrame = title.frame
        let composerFrame = application.otherElements["composer"].frame
        let first = application.staticTexts["sandbox.demo.start"]
        XCTAssertGreaterThanOrEqual(first.frame.minY - header.frame.maxY, 15)
        assertActionsAndTitle()
        capture("header-demo-top")
        let scroll = contentScroll
        scroll.swipeUp()
        XCTAssertTrue(application.otherElements["header.scrolled"].waitForExistence(timeout: 5))
        XCTAssertEqual(title.frame, titleFrame)
        XCTAssertEqual(application.otherElements["composer"].frame, composerFrame)
        capture("header-demo-scrolled")
        for _ in 0..<12 where !application.staticTexts["sandbox.demo.end"].isHittable { scroll.swipeUp() }
        XCTAssertTrue(application.staticTexts["sandbox.demo.end"].isHittable)
        for _ in 0..<12 where !application.otherElements["header"].exists { scroll.swipeDown() }
        XCTAssertTrue(application.otherElements["header"].waitForExistence(timeout: 5))
        XCTAssertEqual(title.frame, titleFrame)
        capture("header-demo-returned")
        application.buttons["header.back"].tap()
        XCTAssertTrue(application.buttons["sandbox.open"].waitForExistence(timeout: 5))
    }

    func testOptionsAreLocalizedAndSessionActionWaitsForHostHandler() {
        for (locale, label, item) in [
            ("en", "Conversation options", "New conversation"),
            ("id", "Opsi percakapan", "Percakapan baru"),
            ("zh-Hans", "对话选项", "新对话")
        ] {
            launch(locale: locale)
            XCTAssertTrue(application.buttons["chat.more"].waitForExistence(timeout: 10))
            assertActionsAndTitle()
            XCTAssertEqual(application.buttons["chat.more"].label, label)
            application.buttons["chat.more"].tap()
            let action = application.buttons[item]
            XCTAssertTrue(action.waitForExistence(timeout: 5))
            XCTAssertFalse(action.isEnabled)
            application.terminate()
        }
    }

    func testHeaderStaysFixedWithKeyboardAndLargeSystemText() {
        launch(
            locale: "zh-Hans",
            extra: [
                "--header-demo", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"
            ])
        let input = application.textViews["composer.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        let titleFrame = application.staticTexts["header.title"].frame
        input.tap()
        input.typeText("First\nSecond\nThird\nFourth\nFifth")
        XCTAssertEqual(application.staticTexts["header.title"].frame, titleFrame)
        let send = application.buttons["composer.send"]
        XCTAssertTrue(send.isHittable)
        XCTAssertLessThanOrEqual(send.frame.maxY, application.keyboards.firstMatch.frame.minY + 1)
        assertActionsAndTitle()
        contentScroll.swipeUp()
        XCTAssertTrue(application.otherElements["header.scrolled"].waitForExistence(timeout: 5))
        XCTAssertEqual(application.staticTexts["header.title"].frame, titleFrame)
        application.buttons["header.back"].tap()
        XCTAssertTrue(application.buttons["sandbox.open"].waitForExistence(timeout: 5))
    }

    private func assertActionsAndTitle() {
        let back = application.buttons["header.back"].frame
        let more = application.buttons["chat.more"].frame
        let title = application.staticTexts["header.title"].frame
        let actionSize = (24 * application.frame.width / 375).rounded()
        XCTAssertEqual(back.width, actionSize, accuracy: 1)
        XCTAssertEqual(back.height, actionSize, accuracy: 1)
        XCTAssertEqual(more.width, actionSize, accuracy: 1)
        XCTAssertEqual(more.height, actionSize, accuracy: 1)
        XCTAssertEqual(title.midX, application.frame.midX, accuracy: 1)
        XCTAssertGreaterThanOrEqual(title.minX, back.maxX)
        XCTAssertLessThanOrEqual(title.maxX, more.minX)
    }

    /// Scroll konten demo. `scrollViews.firstMatch` bisa menunjuk bar saran keyboard.
    private var contentScroll: XCUIElement {
        application.scrollViews.containing(.staticText, identifier: "sandbox.demo.start").firstMatch
    }

    private func launch(locale: String, extra: [String] = []) {
        application.launchArguments = ["--language", locale] + extra
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
