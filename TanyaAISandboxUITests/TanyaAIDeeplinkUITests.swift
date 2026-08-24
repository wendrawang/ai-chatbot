import XCTest

final class TanyaAIDeeplinkUITests: XCTestCase {
    private var application: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        application = XCUIApplication()
        application.launchArguments = ["--deeplink"]
        application.launch()
    }

    func testActionReturnsToDashboardBeforeOpeningTheDestination() {
        openTanyaAIFromLegacyDetail()

        tap("action.open-transfer")

        assertDestination(
            title: "Transfer Form",
            parameter: "0000111122"
        )
        capture(name: "deeplink-transfer-form")
    }

    func testApprovalHandsOffInsteadOfOpeningThePINSheet() {
        openTanyaAIFromLegacyDetail()

        reveal("approval.open.transfer")
        tap("approval.open.transfer")

        XCTAssertFalse(
            application.otherElements["pin.sheet"]
                .waitForExistence(timeout: 3)
        )
        assertDestination(title: "Transfer Form", parameter: "1250000")
    }

    func testUnknownRouteIsIgnoredAndKeepsTheFeatureOpen() {
        openTanyaAIFromLegacyDetail()

        reveal("action.open-blocked")
        tap("action.open-blocked")

        let messageList = application.scrollViews["chat.messageList"]
        RunLoop.current.run(until: Date().addingTimeInterval(1.5))
        XCTAssertTrue(messageList.exists)
        XCTAssertFalse(
            application.navigationBars["Transfer Form"].exists
        )
    }

    private func openTanyaAIFromLegacyDetail() {
        XCTAssertTrue(
            application.navigationBars["Legacy Home"]
                .waitForExistence(timeout: 5)
        )
        application.buttons["Open legacy detail"].tap()
        XCTAssertTrue(
            application.navigationBars["Legacy Detail"]
                .waitForExistence(timeout: 5)
        )

        application.buttons[
            "Open Tanya AI outside legacy navigation"
        ].tap()
        XCTAssertTrue(
            application.scrollViews["chat.messageList"]
                .waitForExistence(timeout: 10)
        )
        waitForStreamToFinish()
    }

    /// The destination must sit directly on the dashboard: the legacy detail
    /// screen is popped first, so its back button reads "Legacy Home".
    private func assertDestination(title: String, parameter: String) {
        let navigationBar = application.navigationBars[title]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 10))
        XCTAssertTrue(navigationBar.buttons["Legacy Home"].exists)
        XCTAssertFalse(application.scrollViews["chat.messageList"].exists)
        XCTAssertTrue(
            application.staticTexts[parameter].waitForExistence(timeout: 5)
        )
    }

    private func reveal(_ identifier: String) {
        let element = application.buttons[identifier]
        let messageList = application.scrollViews["chat.messageList"]
        for _ in 0..<8 where element.isHittable == false {
            messageList.swipeUp()
        }
        XCTAssertTrue(
            element.isHittable,
            "Could not reveal action: \(identifier)"
        )
    }

    private func tap(_ identifier: String) {
        let element = application.buttons[identifier]
        XCTAssertTrue(element.waitForExistence(timeout: 5))
        element.tap()
    }

    private func waitForStreamToFinish() {
        let stopButton = application.buttons["Stop response"]
        let deadline = Date().addingTimeInterval(12)
        while stopButton.exists, Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        XCTAssertFalse(stopButton.exists)
    }

    private func capture(name: String) {
        let attachment = XCTAttachment(screenshot: application.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
