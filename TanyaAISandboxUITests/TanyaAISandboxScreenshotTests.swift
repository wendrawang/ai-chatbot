import XCTest

final class TanyaAISandboxScreenshotTests: XCTestCase {
    private var application: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        application = XCUIApplication()
        application.launchArguments = ["--showcase"]
        application.launch()
    }

    func testEveryFinancialBubbleScenarioAndPINSheet() {
        let messageList = application.scrollViews["chat.messageList"]
        XCTAssertTrue(messageList.waitForExistence(timeout: 10))
        waitForShowcaseToFinish()
        moveToTop(messageList)

        scenarios.forEach { scenario in
            reveal(scenario.anchorText, in: messageList)
            capture(name: scenario.screenshotName)
            if scenario.anchorText == "Confirm your transfer" {
                capturePINSheet(in: messageList)
            }
        }

        XCTAssertTrue(
            application.buttons["Suggested question: Currency"].exists
        )
        XCTAssertTrue(
            application.buttons["Suggested question: Time deposit"].exists
        )
    }

    func testValidPINCompletesConfirmation() {
        let messageList = application.scrollViews["chat.messageList"]
        XCTAssertTrue(messageList.waitForExistence(timeout: 10))
        waitForShowcaseToFinish()
        moveToTop(messageList)
        reveal("Confirm your transfer", in: messageList)
        let confirmButton = application.buttons["approval.open.transfer"]
        XCTAssertTrue(confirmButton.isHittable)
        confirmButton.tap()
        XCTAssertTrue(
            application.otherElements["pin.sheet"]
                .waitForExistence(timeout: 5)
        )

        [1, 2, 3, 4, 5, 6].forEach { digit in
            application.buttons["Digit \(digit)"].tap()
        }

        XCTAssertFalse(
            application.otherElements["pin.sheet"]
                .waitForExistence(timeout: 3)
        )
        XCTAssertFalse(confirmButton.exists)
    }

    func testSuggestionsDoNotCoverLatestBubble() {
        let messageList = application.scrollViews["chat.messageList"]
        XCTAssertTrue(messageList.waitForExistence(timeout: 10))
        waitForShowcaseToFinish()

        let latestBubble = application.staticTexts[
            "Update the app to view this sample card."
        ]
        let suggestion = application.buttons[
            "Suggested question: Currency"
        ]
        XCTAssertTrue(latestBubble.waitForExistence(timeout: 5))
        XCTAssertTrue(suggestion.waitForExistence(timeout: 5))
        capture(name: "suggestion-safe-layout")
        XCTAssertTrue(
            waitUntilHittable(latestBubble),
            "Bubble: \(latestBubble.frame), table: \(messageList.frame)"
        )
        XCTAssertLessThanOrEqual(
            latestBubble.frame.maxY,
            messageList.frame.maxY + 1
        )
        XCTAssertLessThanOrEqual(
            messageList.frame.maxY,
            suggestion.frame.minY + 1
        )
    }

    private func waitUntilHittable(_ element: XCUIElement) -> Bool {
        let predicate = NSPredicate(format: "hittable == true")
        let expectation = XCTNSPredicateExpectation(
            predicate: predicate,
            object: element
        )
        return XCTWaiter.wait(for: [expectation], timeout: 5) == .completed
    }

    private func capturePINSheet(in messageList: XCUIElement) {
        let confirmButton = application.buttons["approval.open.transfer"]
        for _ in 0..<4 where confirmButton.isHittable == false {
            scrollForward(messageList)
        }
        XCTAssertTrue(confirmButton.isHittable)
        confirmButton.tap()
        XCTAssertTrue(
            application.otherElements["pin.sheet"]
                .waitForExistence(timeout: 5)
        )
        capture(name: "pin-bottom-sheet")
        let closeButton = application.buttons["Cancel authorization"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 3))
        closeButton.tap()
    }

    private var scenarios: [ScreenshotScenario] {
        [
            ScreenshotScenario("Confirm currency conversion", "confirmation-currency"),
            ScreenshotScenario("Conversion complete", "receipt-success"),
            ScreenshotScenario("Confirm time deposit", "confirmation-deposit"),
            ScreenshotScenario("Confirm your transfer", "confirmation-transfer"),
            ScreenshotScenario("Confirm savings plan", "confirmation-savings"),
            ScreenshotScenario("Sample transfer limit", "information-card"),
            ScreenshotScenario("Portfolio summary", "portfolio-summary"),
            ScreenshotScenario("Your mutual funds", "mutual-fund-list"),
            ScreenshotScenario("Spending · month to date", "spending-chart"),
            ScreenshotScenario("Bills paid · July", "paid-bills-list"),
            ScreenshotScenario("Incoming · last 30 days", "incoming-funds-list"),
            ScreenshotScenario("A neutral system update.", "status-neutral"),
            ScreenshotScenario("The sample request completed.", "status-success"),
            ScreenshotScenario("Review this demo warning.", "status-warning"),
            ScreenshotScenario("A recoverable demo error occurred.", "status-error"),
            ScreenshotScenario(
                "Update the app to view this sample card.",
                "unsupported-fallback"
            )
        ]
    }

    private func reveal(
        _ anchorText: String,
        in table: XCUIElement
    ) {
        let element = application.staticTexts[anchorText]
        for _ in 0..<36 where element.isHittable == false {
            scrollForward(table)
        }
        XCTAssertTrue(
            element.isHittable,
            "Could not reveal screenshot scenario: \(anchorText)"
        )
        alignNearTop(element, in: table)
        RunLoop.current.run(until: Date().addingTimeInterval(0.2))
    }

    private func alignNearTop(
        _ element: XCUIElement,
        in table: XCUIElement
    ) {
        let targetPosition = application.frame.height * 0.50
        for _ in 0..<8 where element.frame.midY > targetPosition {
            scrollForward(table)
        }
    }

    private func moveToTop(_ table: XCUIElement) {
        for _ in 0..<18 {
            table.swipeDown()
        }
    }

    private func scrollForward(_ table: XCUIElement) {
        let start = table.coordinate(
            withNormalizedOffset: CGVector(dx: 0.5, dy: 0.68)
        )
        let end = table.coordinate(
            withNormalizedOffset: CGVector(dx: 0.5, dy: 0.42)
        )
        start.press(forDuration: 0.05, thenDragTo: end)
    }

    private func waitForShowcaseToFinish() {
        let stopButton = application.buttons["Stop response"]
        let deadline = Date().addingTimeInterval(12)
        while stopButton.exists, Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        XCTAssertFalse(stopButton.exists)
    }

    private func capture(name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

private struct ScreenshotScenario {
    let anchorText: String
    let screenshotName: String

    init(_ anchorText: String, _ screenshotName: String) {
        self.anchorText = anchorText
        self.screenshotName = screenshotName
    }
}
