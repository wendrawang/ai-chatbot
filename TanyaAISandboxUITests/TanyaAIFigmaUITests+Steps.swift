import XCTest

extension TanyaAIFigmaUITests {
    func showProductSelection() {
        application.buttons["quick.action.portfolio"].tap()
        reveal(application.buttons["response.action.portfolio-performance"])
        capture("figma-portfolio-bullets")
        tapAction("portfolio-performance")
        reveal(application.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "+3.600.000")).firstMatch)
        capture("figma-investment-three-column-table")
        tapAction("investment-optimize")
        tapAction("optimization-products")
        reveal(application.buttons["response.action.products-purchase"])
        capture("figma-product-two-column-table")
        tapAction("products-purchase")
        reveal(application.buttons["option.fund-manulife"])
        capture("figma-product-options-unselected")
    }

    func chooseProduct() {
        let selected = application.buttons["option.fund-manulife"]
        selected.tap()
        reveal(application.buttons["response.action.metric-buy"])
        capture("figma-product-nab-summary")
        reveal(selected, isForward: false)
        XCTAssertTrue(selected.exists)
        XCTAssertTrue(selected.isSelected)
        XCTAssertFalse(selected.isEnabled)
        XCTAssertFalse(application.buttons["option.fund-obligasi"].isEnabled)
        XCTAssertFalse(application.buttons["option.fund-ekuitas"].isEnabled)
        capture("figma-product-options-read-only")
    }

    func acceptDocument(_ identifier: String) {
        let document = application.buttons["document.\(identifier)"]
        reveal(document)
        document.tap()
        let accept = application.buttons["sandbox.document.accept"]
        XCTAssertTrue(accept.waitForExistence(timeout: 5))
        XCTAssertFalse(application.buttons["sandbox.document.continue"].isEnabled)
        capture("figma-existing-host-document-\(identifier)")
        accept.tap()
        application.buttons["sandbox.document.continue"].tap()
        XCTAssertTrue(application.textViews.firstMatch.waitForExistence(timeout: 5))
    }

    func send(_ text: String, isKeyboardDismissed: Bool = true) {
        let input = application.textViews.firstMatch
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        input.tap()
        input.typeText(text)
        let send = application.buttons["Kirim pesan"]
        XCTAssertTrue(send.isEnabled)
        send.tap()
        let table = application.tables["chat.messageTable"]
        if isKeyboardDismissed, application.keyboards.firstMatch.exists { table.swipeDown() }
    }

    func tapAction(_ identifier: String) {
        let action = application.buttons["response.action.\(identifier)"]
        reveal(action)
        action.tap()
    }

    func reveal(_ element: XCUIElement, isForward: Bool = true) {
        let table = application.tables["chat.messageTable"]
        for _ in 0..<16 {
            if element.exists, !element.frame.isEmpty, table.frame.contains(element.frame) { break }
            let latest = application.buttons["chat.latest"]
            if isForward, latest.exists, latest.isHittable {
                latest.tap()
            } else if isForward {
                table.swipeUp()
            } else {
                table.swipeDown()
            }
        }
        XCTAssertTrue(element.exists)
    }

    func inlineLink(containing label: String) -> XCUIElement {
        application.links.matching(NSPredicate(format: "label CONTAINS %@", label)).firstMatch
    }

    func capture(_ name: String) {
        if !application.keyboards.firstMatch.exists, application.textViews.firstMatch.isHittable {
            assertComposerAtBottom()
        }
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func assertComposerAtBottom() {
        let lowerEdge = application.frame.maxY - 100
        let predicate = NSPredicate { object, _ in
            guard let input = object as? XCUIElement else { return false }
            return input.frame.maxY > lowerEdge
        }
        let settled = XCTNSPredicateExpectation(predicate: predicate, object: application.textViews.firstMatch)
        XCTAssertEqual(XCTWaiter.wait(for: [settled], timeout: 5), .completed)
    }
}
