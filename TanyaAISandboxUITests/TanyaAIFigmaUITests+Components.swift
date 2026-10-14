import XCTest

extension TanyaAIFigmaUITests {
    func testMediaSuggestionsAndUnderlinedDestinationRenderInConversation() {
        send("Contoh komponen")
        let link = application.buttons["response.action.components-link"]
        reveal(link)
        XCTAssertTrue(application.staticTexts["Bonus bunga tabungan"].exists)
        capture("figma-components-media-and-actions")
        link.tap()
        XCTAssertTrue(application.staticTexts["Webview dalam aplikasi"].waitForExistence(timeout: 5))
        application.buttons["sandbox.host.close"].tap()
        let suggestion = application.buttons["response.action.components-portfolio"]
        reveal(suggestion)
        capture("figma-components-horizontal-suggestions")
        suggestion.tap()
        XCTAssertTrue(application.buttons["response.action.portfolio-performance"].waitForExistence(timeout: 10))
    }
}
