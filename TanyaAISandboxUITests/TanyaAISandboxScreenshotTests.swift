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
        let messageTable = application.tables["chat.messageTable"]
        XCTAssertTrue(messageTable.waitForExistence(timeout: 10))
        waitForShowcaseToFinish()
        moveToTop(messageTable)

        scenarios.forEach { scenario in
            reveal(scenario.anchorText, in: messageTable)
            capture(name: scenario.screenshotName)
            if scenario.anchorText == "Confirm your transfer" {
                capturePINSheet(in: messageTable)
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
        let messageTable = application.tables["chat.messageTable"]
        XCTAssertTrue(messageTable.waitForExistence(timeout: 10))
        waitForShowcaseToFinish()
        moveToTop(messageTable)
        reveal("Confirm your transfer", in: messageTable)
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

    /// The prompts used to sit on a strip below the table, and this checked
    /// that the strip started where the table ended. They are rows in the
    /// conversation now, so the guarantee is expressed where it moved to: the
    /// last reply, then the prompts under it, both inside the table and both
    /// reachable. The property is the same one - nothing covers anything.
    func testSuggestionsDoNotCoverLatestBubble() {
        let messageTable = application.tables["chat.messageTable"]
        XCTAssertTrue(messageTable.waitForExistence(timeout: 10))
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
            "Bubble: \(latestBubble.frame), table: \(messageTable.frame)"
        )
        XCTAssertTrue(
            waitUntilHittable(suggestion),
            "Prompt: \(suggestion.frame), table: \(messageTable.frame)"
        )
        XCTAssertLessThanOrEqual(
            latestBubble.frame.maxY,
            suggestion.frame.minY + 1
        )
        XCTAssertLessThanOrEqual(
            suggestion.frame.maxY,
            messageTable.frame.maxY + 1
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

    private func capturePINSheet(in messageTable: XCUIElement) {
        let confirmButton = application.buttons["approval.open.transfer"]
        for _ in 0..<4 where confirmButton.isHittable == false {
            scrollForward(messageTable)
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
            ScreenshotScenario(
                "Jalani misinya, dapatkan Bonus Bunga Tabungan hingga 5,25% p.a.",
                "image-promo"
            ),
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
            // Order matters: `reveal` only scrolls forward, so a scenario
            // listed before the bubble it names can never be found again.
            ScreenshotScenario(
                "Kategori apa yang diinginkan",
                "choices-card"
            ),
            ScreenshotScenario(
                "Anda akan diarahkan ke agen kami",
                "live-agent-card"
            ),
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
        for _ in 0..<36 where isVisible(element, in: table) == false {
            scrollForward(table)
        }
        XCTAssertTrue(
            isVisible(element, in: table),
            "Could not reveal screenshot scenario: \(anchorText)"
        )
        alignNearTop(element, in: table)
        RunLoop.current.run(until: Date().addingTimeInterval(0.2))
    }

    // Offscreen static text can have no activation point. Screenshots need
    // visible bounds, not a tappable accessibility activation point.
    private func isVisible(_ element: XCUIElement, in table: XCUIElement) -> Bool {
        guard element.exists else { return false }
        let frame = element.frame
        return !frame.isEmpty && table.frame.intersection(application.frame).contains(frame)
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
