//
//  StartingPointUITests.swift
//  TanyaAISandboxUITests
//
//  Created by Wendra on 15/10/26.
//

import XCTest

final class StartingPointUITests: XCTestCase {
    private var application: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        application = XCUIApplication()
    }

    func testThreeLanguagesShowLocalizedEmptyComposer() {
        for (locale, label) in [("en", "Send message"), ("id", "Kirim pesan"), ("zh-Hans", "发送消息")] {
            launch(locale: locale)
            let input = application.textViews["composer.input"]
            let send = application.buttons["composer.send"]
            XCTAssertTrue(input.waitForExistence(timeout: 10))
            XCTAssertFalse(send.isEnabled)
            XCTAssertEqual(send.label, label)
            XCTAssertFalse(input.label.isEmpty)
            XCTAssertLessThanOrEqual(input.frame.maxX, send.frame.minX + 1)
            XCTAssertEqual(input.frame.midY, send.frame.midY, accuracy: 1)
            capture("starter-" + locale)
            application.terminate()
        }
    }

    func testFourLineLimitLongWordAndAcceptedSend() {
        launch(locale: "en")
        let input = application.textViews["composer.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        input.tap()
        input.typeText("First")
        let firstHeight = input.frame.height
        let initialWidth = input.frame.width
        let send = application.buttons["composer.send"]
        let initialButtonCenter = send.frame.midY
        XCTAssertEqual(input.frame.midY, initialButtonCenter, accuracy: 1)
        capture("starter-one-line-keyboard")
        input.typeText("\nSecond\nThird\nFourth")
        let fourthHeight = input.frame.height
        XCTAssertGreaterThan(fourthHeight, firstHeight)
        XCTAssertEqual(send.frame.midY, initialButtonCenter, accuracy: 1)
        XCTAssertGreaterThan(send.frame.midY, input.frame.midY)
        input.typeText("\nFifth\n" + String(repeating: "m", count: 128))
        XCTAssertEqual(input.frame.height, fourthHeight, accuracy: 1)
        XCTAssertEqual(input.frame.width, initialWidth, accuracy: 1)
        XCTAssertEqual(send.frame.midY, initialButtonCenter, accuracy: 1)
        XCTAssertTrue(send.isHittable)
        XCTAssertGreaterThanOrEqual(send.frame.width, 44)
        XCTAssertGreaterThanOrEqual(send.frame.height, 44)
        XCTAssertLessThanOrEqual(input.frame.maxX, send.frame.minX + 1)
        XCTAssertLessThanOrEqual(send.frame.maxY, application.keyboards.firstMatch.frame.minY + 1)
        assertVisualInsets(isMultiline: true)
        capture("starter-four-lines-keyboard")
        send.tap()
        XCTAssertEqual(input.value as? String, "")
        XCTAssertFalse(send.isEnabled)
        XCTAssertEqual(input.frame.midY, send.frame.midY, accuracy: 1)
    }

    func testVisualInsetsAndEdgesOfTapTarget() {
        launch(locale: "en")
        let input = application.textViews["composer.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        assertVisualInsets(isMultiline: false)
        input.tap()
        let send = application.buttons["composer.send"]
        for (horizontal, vertical) in [(0.05, 0.5), (0.95, 0.5), (0.5, 0.05), (0.5, 0.95)] {
            input.typeText("Tap edge")
            send.coordinate(withNormalizedOffset: CGVector(dx: horizontal, dy: vertical)).tap()
            XCTAssertEqual(input.value as? String, "")
            XCTAssertFalse(send.isEnabled)
        }
    }

    func testWhitespaceCannotBeSubmitted() {
        launch(locale: "id")
        let input = application.textViews["composer.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        input.tap()
        input.typeText("   \n  ")
        XCTAssertFalse(application.buttons["composer.send"].isEnabled)
    }

    func testRejectedSubmissionKeepsDraft() {
        launch(locale: "en", extra: ["--reject-send"])
        let input = application.textViews["composer.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        input.tap()
        input.typeText("Keep my draft")
        application.buttons["composer.send"].tap()
        XCTAssertEqual(input.value as? String, "Keep my draft")
    }

    func testTextSizeSettingKeepsComposerFontAndLayoutFixed() {
        var referenceSizes: [CGSize]?
        for category in ["UICTContentSizeCategoryL", "UICTContentSizeCategoryAccessibilityXXXL"] {
            launch(locale: "zh-Hans", extra: ["-UIPreferredContentSizeCategoryName", category])
            let input = application.textViews["composer.input"]
            XCTAssertTrue(input.waitForExistence(timeout: 10))
            let send = application.buttons["composer.send"]
            XCTAssertEqual(input.frame.midY, send.frame.midY, accuracy: 1)
            let emptySize = input.frame.size
            input.tap()
            input.typeText("First")
            let singleLineSize = input.frame.size
            let initialButtonCenter = send.frame.midY
            XCTAssertEqual(input.frame.midY, initialButtonCenter, accuracy: 1)
            input.typeText("\nSecond\nThird\nFourth\nFifth")
            XCTAssertEqual(send.frame.midY, initialButtonCenter, accuracy: 1)
            XCTAssertGreaterThan(send.frame.midY, input.frame.midY)
            XCTAssertTrue(send.isHittable)
            XCTAssertLessThanOrEqual(input.frame.maxX, send.frame.minX + 1)
            XCTAssertLessThanOrEqual(send.frame.maxX, application.frame.maxX)
            let sizes = [emptySize, singleLineSize, input.frame.size, application.otherElements["composer"].frame.size]
            if let referenceSizes {
                for (actual, reference) in zip(sizes, referenceSizes) {
                    XCTAssertEqual(actual.width, reference.width, accuracy: 1)
                    XCTAssertEqual(actual.height, reference.height, accuracy: 1)
                }
                assertVisualInsets(isMultiline: true)
                capture("starter-accessibility-zh-Hans")
            } else {
                referenceSizes = sizes
            }
            application.terminate()
        }
    }

    func testHostCanCloseAndReopenWithoutNavigationLink() {
        launch(locale: "en")
        let input = application.textViews["composer.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        input.tap()
        input.typeText("Unsaved draft")
        application.buttons["Back"].tap()
        let open = application.buttons["sandbox.open"]
        XCTAssertTrue(open.waitForExistence(timeout: 10))
        XCTAssertTrue(open.isHittable)
        open.tap()
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        XCTAssertEqual(input.value as? String, "")
        XCTAssertFalse(application.buttons["composer.send"].isEnabled)
    }

    private func launch(locale: String, extra: [String] = []) {
        application.launchArguments = ["--language", locale] + extra
        application.launch()
        let open = application.buttons["sandbox.open"]
        XCTAssertTrue(open.waitForExistence(timeout: 10))
        open.tap()
    }

    private func assertVisualInsets(isMultiline: Bool) {
        let composer = application.otherElements["composer"].frame
        let input = application.textViews["composer.input"].frame
        let send = application.buttons["composer.send"].frame
        XCTAssertEqual(send.width, 44, accuracy: 1)
        XCTAssertEqual(send.height, 44, accuracy: 1)
        XCTAssertEqual(input.minX - composer.minX, 16, accuracy: 1)
        XCTAssertEqual(composer.maxX - (send.midX + 12), 16, accuracy: 1)
        XCTAssertEqual(composer.maxY - (send.midY + 12), 16, accuracy: 1)
        if isMultiline {
            XCTAssertEqual(input.minY - composer.minY, 16, accuracy: 1)
        } else {
            XCTAssertEqual(send.midY - 12 - composer.minY, 16, accuracy: 1)
        }
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: application.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
