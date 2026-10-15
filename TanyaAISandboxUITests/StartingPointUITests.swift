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
        input.typeText("\nSecond\nThird\nFourth")
        let fourthHeight = input.frame.height
        XCTAssertGreaterThan(fourthHeight, firstHeight)
        input.typeText("\nFifth\n" + String(repeating: "m", count: 128))
        XCTAssertEqual(input.frame.height, fourthHeight, accuracy: 1)
        XCTAssertEqual(input.frame.width, initialWidth, accuracy: 1)
        let send = application.buttons["composer.send"]
        XCTAssertTrue(send.isHittable)
        XCTAssertGreaterThanOrEqual(send.frame.width, 44)
        XCTAssertGreaterThanOrEqual(send.frame.height, 44)
        XCTAssertLessThanOrEqual(input.frame.maxX, send.frame.minX + 1)
        XCTAssertLessThanOrEqual(send.frame.maxY, application.keyboards.firstMatch.frame.minY + 1)
        capture("starter-four-lines-keyboard")
        send.tap()
        XCTAssertEqual(input.value as? String, "")
        XCTAssertFalse(send.isEnabled)
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

    func testLargestTextKeepsComposerAndActionVisible() {
        launch(
            locale: "zh-Hans",
            extra: ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"])
        let input = application.textViews["composer.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        input.tap()
        input.typeText("First\nSecond\nThird\nFourth\nFifth")
        let send = application.buttons["composer.send"]
        XCTAssertTrue(send.isHittable)
        XCTAssertLessThanOrEqual(input.frame.maxX, send.frame.minX + 1)
        XCTAssertLessThanOrEqual(send.frame.maxX, application.frame.maxX)
        capture("starter-accessibility-zh-Hans")
    }

    private func launch(locale: String, extra: [String] = []) {
        application.launchArguments = ["--language", locale] + extra
        application.launch()
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: application.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
