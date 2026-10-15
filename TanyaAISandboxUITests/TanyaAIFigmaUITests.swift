import XCTest

final class TanyaAIFigmaUITests: XCTestCase {
    var application: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        application = XCUIApplication()
        application.launchArguments = ["--figma"]
        application.launch()
        XCTAssertTrue(application.staticTexts["Hi, Lara Croft!"].waitForExistence(timeout: 10))
    }

    func testWelcomeAndNewSessionResetConversationAndDraft() {
        XCTAssertTrue(application.buttons["quick.action.portfolio"].exists)
        XCTAssertTrue(application.buttons["quick.action.currency"].exists)
        XCTAssertTrue(application.buttons["quick.action.reference"].exists)
        capture("figma-welcome-three-actions")
        send("Cek Portofolio")
        XCTAssertTrue(application.buttons["response.action.portfolio-performance"].waitForExistence(timeout: 10))
        let input = application.textViews.firstMatch
        input.tap()
        input.typeText("Draft sesi sebelumnya")

        application.buttons["chat.newSession"].tap()

        XCTAssertTrue(application.staticTexts["Hi, Lara Croft!"].waitForExistence(timeout: 5))
        XCTAssertFalse(application.keyboards.firstMatch.exists)
        XCTAssertFalse((application.textViews.firstMatch.value as? String)?.contains("Draft sesi sebelumnya") == true)
        XCTAssertFalse(application.buttons["response.action.portfolio-performance"].exists)
        assertComposerAtBottom()
        capture("figma-new-session-empty")
    }

    func testFullPurchaseFlowUsesReadOnlySelectionAndExistingHostPages() {
        showProductSelection()
        chooseProduct()
        tapAction("metric-buy")
        send("5jt")
        reveal(application.buttons["response.action.purchase-confirm"])
        capture("figma-purchase-summary")
        tapAction("purchase-confirm")
        reveal(application.buttons["document.doc-product"])
        XCTAssertFalse(application.buttons["documents.authorize"].exists)
        capture("figma-documents-none-accepted")

        acceptDocument("doc-product")
        XCTAssertTrue(application.buttons["document.doc-product"].isSelected)
        XCTAssertFalse(application.buttons["documents.authorize"].exists)
        capture("figma-documents-one-accepted")
        acceptDocument("doc-terms")
        reveal(application.buttons["documents.authorize"])
        XCTAssertTrue(application.buttons["document.doc-terms"].isSelected)
        capture("figma-documents-both-accepted")
        application.buttons["documents.authorize"].tap()
        let pin = application.descendants(matching: .any)["sandbox.pin.screen"].firstMatch
        XCTAssertTrue(pin.waitForExistence(timeout: 5))
        [1, 2, 3].forEach { application.buttons["keypad.digit.\($0)"].tap() }
        capture("figma-existing-host-pin")
        [4, 5, 6].forEach { application.buttons["keypad.digit.\($0)"].tap() }

        XCTAssertTrue(
            application.staticTexts["Transaksi reksadana sebesar IDR 5.000.000 telah berhasil."]
                .waitForExistence(timeout: 5))
        reveal(application.buttons["response.action.result-history"])
        XCTAssertFalse(application.buttons["documents.authorize"].exists)
        capture("figma-transaction-result")
        application.buttons["response.action.result-history"].tap()
        XCTAssertTrue(application.staticTexts["Deeplink diterima oleh host"].waitForExistence(timeout: 5))
        capture("figma-result-deeplink-host")
    }

    func testInlineLinksOpenInAppWebviewAndHostDeeplink() {
        send("Contoh format teks")
        let webLink = inlineLink(containing: "Buka Google")
        reveal(webLink)
        capture("figma-native-formatted-reply")
        webLink.tap()
        XCTAssertTrue(application.staticTexts["Webview dalam aplikasi"].waitForExistence(timeout: 5))
        XCTAssertTrue(application.webViews["sandbox.webview"].waitForExistence(timeout: 5))
        XCTAssertEqual(application.staticTexts["sandbox.webview.url"].label, "https://www.google.com")
        capture("figma-inline-webview")
        application.buttons["sandbox.host.close"].tap()

        let deeplink = inlineLink(containing: "Lihat portofolio")
        reveal(deeplink)
        deeplink.tap()
        XCTAssertTrue(application.staticTexts["Deeplink diterima oleh host"].waitForExistence(timeout: 5))
        XCTAssertTrue(application.staticTexts["sandbox.deeplink.url"].label.contains("ocbcid://mobile"))
        capture("figma-inline-deeplink")
        application.buttons["sandbox.host.close"].tap()
        XCTAssertTrue(application.textViews.firstMatch.exists)
    }

    func testNewPromptAnchorsNearTopWithPreviousAnswerPreviewAndLatestArrow() {
        application.buttons["quick.action.portfolio"].tap()
        XCTAssertTrue(application.buttons["response.action.portfolio-performance"].waitForExistence(timeout: 10))
        send("Lihat pilihan produk", isKeyboardDismissed: false)
        let prompt = application.staticTexts["Lihat pilihan produk"]
        XCTAssertTrue(prompt.waitForExistence(timeout: 5))
        let table = application.tables["chat.messageTable"]
        let previous = application.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Evaluasi:"))
            .firstMatch
        XCTAssertGreaterThan(prompt.frame.minY, table.frame.minY)
        XCTAssertLessThan(prompt.frame.minY, table.frame.minY + table.frame.height * 0.4)
        XCTAssertTrue(previous.exists)
        XCTAssertGreaterThan(previous.frame.maxY, table.frame.minY)
        XCTAssertLessThanOrEqual(previous.frame.maxY, prompt.frame.minY)
        capture("figma-new-prompt-anchor-and-preview")

        send("Optimalkan investasi yang kurang produktif")
        let latest = application.buttons["chat.latest"]
        XCTAssertTrue(latest.waitForExistence(timeout: 10))
        capture("figma-long-answer-latest-arrow")
        latest.tap()
        reveal(application.buttons["response.action.optimization-products"])
        capture("figma-long-answer-latest")
    }
}
