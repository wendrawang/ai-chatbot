import XCTest

extension TanyaAIFigmaUITests {
    func testStressResponsesWrapWithoutHorizontalOverflow() {
        for command in ["stress table", "stress metric", "stress summary", "stress options"] {
            send(command)
            let table = application.tables["chat.messageTable"]
            XCTAssertTrue(table.waitForExistence(timeout: 5))
            let latest = application.buttons["chat.latest"]
            if latest.waitForExistence(timeout: 2), latest.isHittable { latest.tap() }
            assertVisibleContentWithinScreen()
            capture("figma-" + command.replacingOccurrences(of: " ", with: "-"))
            for _ in 0..<4 {
                table.swipeDown()
                assertVisibleContentWithinScreen()
            }
            capture("figma-" + command.replacingOccurrences(of: " ", with: "-") + "-top")
            application.buttons["chat.newSession"].tap()
            XCTAssertTrue(application.staticTexts["Hi, Lara Croft!"].waitForExistence(timeout: 5))
        }
    }

    func testStressComposerLongWordAndFourLineLimit() {
        let input = application.textViews.firstMatch
        input.tap()
        input.typeText("First line")
        let initialWidth = input.frame.width
        let firstHeight = input.frame.height
        let send = application.buttons["Kirim pesan"]
        input.typeText("\nSecond line\nThird line\nFourth line")
        let fourthHeight = input.frame.height
        XCTAssertGreaterThan(fourthHeight, firstHeight)
        input.typeText("\nFifth line\n" + String(repeating: "m", count: 128))
        XCTAssertEqual(input.frame.height, fourthHeight, accuracy: 1)
        XCTAssertEqual(input.frame.width, initialWidth, accuracy: 1)
        XCTAssertTrue(send.isHittable)
        XCTAssertGreaterThanOrEqual(send.frame.width, 44)
        XCTAssertLessThanOrEqual(input.frame.maxX, send.frame.minX + 1)
        XCTAssertLessThanOrEqual(send.frame.maxX, application.frame.maxX)
        capture("figma-stress-composer-keyboard")
        send.tap()
        XCTAssertTrue(
            application.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "First line"))
                .firstMatch.waitForExistence(timeout: 5))
        assertVisibleContentWithinScreen()
    }

    func testWelcomeActionsRemainReachableWhenTextIsLarge() {
        let welcome = application.scrollViews.firstMatch
        let reference = application.buttons["quick.action.reference"]
        for _ in 0..<8 where !reference.isHittable { welcome.swipeUp() }
        XCTAssertTrue(reference.isHittable)
        capture("figma-stress-welcome")
        reference.tap()
        XCTAssertTrue(application.buttons["response.action.demo-portfolio"].waitForExistence(timeout: 10))
        assertVisibleContentWithinScreen()
    }

    private func assertVisibleContentWithinScreen() {
        let screen = application.frame
        let elements = application.staticTexts.allElementsBoundByIndex + application.buttons.allElementsBoundByIndex
        for element in elements where element.exists && !element.frame.isEmpty && screen.intersects(element.frame) {
            XCTAssertGreaterThanOrEqual(element.frame.minX, screen.minX - 1, element.label)
            XCTAssertLessThanOrEqual(element.frame.maxX, screen.maxX + 1, element.label)
        }
    }
}
