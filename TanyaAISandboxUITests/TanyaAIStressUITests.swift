import XCTest

final class TanyaAIStressUITests: XCTestCase {
    private var application: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        application = XCUIApplication()
        application.launchArguments = ["--stress-chat"]
        application.launch()
    }

    func testFiveThousandMessagesRemainScrollableAndReachLatestBubble() {
        let messageList = application.scrollViews["chat.messageList"]
        XCTAssertTrue(messageList.waitForExistence(timeout: 10))

        let latestMessage = application.staticTexts["Stress message 5000"]
        XCTAssertTrue(latestMessage.waitForExistence(timeout: 30))
        XCTAssertTrue(waitUntilHittable(latestMessage))
        XCTAssertTrue(
            application.buttons["Suggested question: Next sample"].exists
        )
        captureScreenshot(name: "stress-5000-messages")

        for _ in 0..<8 {
            messageList.swipeDown(velocity: .fast)
            messageList.swipeUp(velocity: .fast)
        }

        let visibleMessages = application.staticTexts.matching(
            NSPredicate(format: "label BEGINSWITH 'Stress message'")
        ).allElementsBoundByIndex
        XCTAssertTrue(visibleMessages.contains { $0.isHittable })
        XCTAssertTrue(messageList.isHittable)
        captureScreenshot(name: "stress-after-rapid-scroll")
    }

    private func waitUntilHittable(_ element: XCUIElement) -> Bool {
        let predicate = NSPredicate(format: "hittable == true")
        let expectation = XCTNSPredicateExpectation(
            predicate: predicate,
            object: element
        )
        return XCTWaiter.wait(for: [expectation], timeout: 10) == .completed
    }

    private func captureScreenshot(name: String) {
        let attachment = XCTAttachment(screenshot: application.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
