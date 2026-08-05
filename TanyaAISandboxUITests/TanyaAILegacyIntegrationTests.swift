import XCTest

final class TanyaAILegacyIntegrationTests: XCTestCase {
    private var application: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        application = XCUIApplication()
        application.launch()
    }

    func testTanyaAIPreservesLegacyNavigationState() {
        openLegacyDetail()
        application.buttons["Increase legacy state"].tap()
        assertLegacyCounterEqualsOne()
        capture(name: "legacy-navigation-detail")

        application.buttons[
            "Open Tanya AI outside legacy navigation"
        ].tap()

        let messageList = application.scrollViews["chat.messageList"]
        XCTAssertTrue(messageList.waitForExistence(timeout: 5))
        XCTAssertFalse(application.staticTexts["Legacy state: 1"].isHittable)
        capture(name: "legacy-tanya-ai-full-screen")

        application.buttons["Close Tanya AI"].tap()
        assertLegacyCounterEqualsOne()
        capture(name: "legacy-navigation-restored")
    }

    private func openLegacyDetail() {
        let legacyHome = application.navigationBars["Legacy Home"]
        XCTAssertTrue(legacyHome.waitForExistence(timeout: 5))
        application.buttons["Open legacy detail"].tap()

        let legacyDetail = application.navigationBars["Legacy Detail"]
        XCTAssertTrue(legacyDetail.waitForExistence(timeout: 5))
    }

    private func assertLegacyCounterEqualsOne() {
        let counter = application.staticTexts["Legacy state: 1"]
        XCTAssertTrue(counter.waitForExistence(timeout: 5))
    }

    private func capture(name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
