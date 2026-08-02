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

    func testBubblePermutationsAndPINSheet() {
        let messageTable = application.tables["chat.messageTable"]
        XCTAssertTrue(messageTable.waitForExistence(timeout: 10))
        waitForShowcaseToFinish()

        swipe(messageTable, direction: .up, count: 6)
        capture(name: "bubble-showcase-bottom")
        swipe(messageTable, direction: .down, count: 3)
        capture(name: "bubble-showcase-middle")
        swipe(messageTable, direction: .down, count: 6)
        capture(name: "bubble-showcase-top")

        openApproval(in: messageTable)
        let firstDigit = application.buttons["Digit 1"]
        XCTAssertTrue(firstDigit.waitForExistence(timeout: 5))
        capture(name: "pin-bottom-sheet")
    }

    private func waitForShowcaseToFinish() {
        let stopButton = application.buttons["Stop response"]
        let deadline = Date().addingTimeInterval(10)
        while stopButton.exists, Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        XCTAssertFalse(stopButton.exists)
    }

    private func openApproval(in table: XCUIElement) {
        let approvalButton = application.buttons["approval.open"]
        for _ in 0..<6 where approvalButton.exists == false {
            table.swipeUp()
        }
        if approvalButton.exists == false {
            for _ in 0..<6 where approvalButton.exists == false {
                table.swipeDown()
            }
        }
        XCTAssertTrue(approvalButton.exists)
        approvalButton.tap()
    }

    private func capture(name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func swipe(
        _ element: XCUIElement,
        direction: SwipeDirection,
        count: Int
    ) {
        for _ in 0..<count {
            switch direction {
            case .up: element.swipeUp()
            case .down: element.swipeDown()
            }
        }
    }
}

private enum SwipeDirection {
    case up
    case down
}
