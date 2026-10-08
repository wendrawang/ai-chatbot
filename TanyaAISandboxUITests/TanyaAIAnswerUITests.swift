import XCTest

final class TanyaAIAnswerUITests: XCTestCase {
    func testRadioBecomesPromptAndOnlyOptionsDisappear() {
        let application = XCUIApplication()
        application.launchArguments = ["--answers"]
        application.launch()
        let option = application.buttons["option.product"]
        XCTAssertTrue(option.waitForExistence(timeout: 10))
        let table = application.tables["chat.messageTable"]
        for _ in 0..<4 where option.isHittable == false { table.swipeDown() }
        XCTAssertTrue(option.isHittable)
        capture("answer-before-selection")
        option.tap()
        XCTAssertTrue(application.staticTexts["Pilihan diterima."].waitForExistence(timeout: 5))
        XCTAssertFalse(application.buttons["option.product"].exists)
        XCTAssertFalse(application.buttons["option.support"].exists)
        XCTAssertTrue(application.staticTexts["Informasi produk"].exists)
        XCTAssertTrue(application.staticTexts["Pilih informasi yang ingin Anda lihat."].exists)
        XCTAssertTrue(application.staticTexts["Promo produk pilihan"].exists)
        XCTAssertTrue(application.buttons["action.link-3"].exists)
        capture("answer-after-selection")
    }

    func testScrollUpShowsArrowAndTapReturnsToLatest() {
        let application = XCUIApplication()
        application.launchArguments = ["--showcase"]
        application.launch()
        let table = application.tables["chat.messageTable"]
        XCTAssertTrue(application.buttons["Currency"].waitForExistence(timeout: 10))
        let latest = application.buttons["chat.latest"]
        XCTAssertFalse(latest.exists)
        table.swipeDown()
        XCTAssertTrue(latest.waitForExistence(timeout: 5))
        capture("scroll-to-latest-visible")
        latest.tap()
        let hidden = NSPredicate(format: "exists == false")
        expectation(for: hidden, evaluatedWith: latest)
        waitForExpectations(timeout: 5)
        XCTAssertTrue(application.buttons["Currency"].isHittable)
        capture("scroll-to-latest-completed")
    }

    func testComposerGrowsToFourLinesThenKeepsItsHeight() {
        let application = XCUIApplication()
        application.launchArguments = ["--answers"]
        application.launch()
        let input = application.textViews.firstMatch
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        input.tap()
        input.typeText("First line")
        let singleHeight = input.frame.height
        capture("composer-review-one-line")
        input.typeText("\nSecond line\nThird line\nFourth line")
        let fourLineHeight = input.frame.height
        XCTAssertGreaterThan(fourLineHeight, singleHeight)
        capture("composer-review-four-lines")
        input.typeText("\nFifth line\nSixth line")
        XCTAssertEqual(input.frame.height, fourLineHeight, accuracy: 1)
        XCTAssertTrue((input.value as? String)?.contains("Sixth line") == true)
        capture("composer-review-over-four-lines")
    }

    func testLongWordKeepsSendButtonInsideComposer() {
        let application = XCUIApplication()
        application.launchArguments = ["--answers"]
        application.launch()
        let input = application.textViews.firstMatch
        let send = application.buttons["Send message"]
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        XCTAssertTrue(send.exists)
        input.tap()
        let initialWidth = input.frame.width
        input.typeText(String(repeating: "m", count: 128))
        capture("composer-long-word")
        XCTAssertTrue(send.isHittable)
        XCTAssertEqual(input.frame.width, initialWidth, accuracy: 1)
        XCTAssertLessThanOrEqual(input.frame.maxX, send.frame.minX + 1)
        XCTAssertLessThanOrEqual(send.frame.maxX, application.frame.maxX)
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
