import XCTest

final class PreviewBookUITests: XCTestCase {
    var application: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        application = XCUIApplication()
        application.launchArguments = ["--previewbook"]
        application.launch()
        XCTAssertTrue(application.navigationBars["PreviewBook"].waitForExistence(timeout: 10))
    }

    func testAllComponentPagesRenderAndStayWithinDeviceWidth() {
        capture("previewbook-catalog")
        for entry in [
            "composer", "selection", "text", "media", "table", "metric", "summary", "documents",
            "actions", "welcome", "chrome", "feedback", "artwork"
        ] {
            openPage(entry)
            let scroll = application.scrollViews.firstMatch
            XCTAssertLessThanOrEqual(scroll.frame.width, application.frame.width + 1, entry)
            capture("previewbook-\(entry)")
            if ["media", "table", "actions", "summary", "text", "composer"].contains(entry) {
                scroll.swipeUp()
                capture("previewbook-\(entry)-scrolled")
            }
            application.navigationBars.buttons.firstMatch.tap()
            XCTAssertTrue(application.navigationBars["PreviewBook"].waitForExistence(timeout: 5))
        }
    }

    func testComposerEmptyMultilineSendAndStopCallback() {
        openPage("composer")
        let send = application.buttons["composer.send"].firstMatch
        XCTAssertFalse(send.isEnabled)
        application.buttons["preview.composer.fill"].tap()
        XCTAssertTrue(send.isEnabled)
        let input = application.textViews.firstMatch
        XCTAssertLessThanOrEqual(input.frame.maxX, send.frame.minX + 1)
        capture("previewbook-composer-multiline")
        send.tap()
        XCTAssertEqual(input.value as? String, "")
        XCTAssertFalse(send.isEnabled)

        application.switches["preview.composer.generating"].tap()
        let stop = application.buttons["composer.stop"].firstMatch
        XCTAssertTrue(stop.isEnabled)
        capture("previewbook-composer-stop")
        stop.tap()
        XCTAssertEqual(application.staticTexts["preview.feedback"].label, "Proses dihentikan oleh callback")
        XCTAssertFalse(application.buttons["Stop tidak tersedia"].isEnabled)
    }

    func testSelectionBecomesReadonlyAndResetRestoresInteraction() {
        openPage("selection")
        let option = application.buttons["option.first"].firstMatch
        XCTAssertTrue(option.isEnabled)
        option.tap()
        XCTAssertTrue(option.isSelected)
        XCTAssertFalse(application.buttons["option.second"].firstMatch.isEnabled)
        capture("previewbook-options-readonly")
        let reset = application.buttons["preview.selection.reset"]
        reveal(reset)
        reset.tap()
        XCTAssertTrue(option.isEnabled)
        XCTAssertFalse(option.isSelected)
    }

    func testDocumentContinuationWaitsForBothAcceptedResults() {
        openPage("documents")
        XCTAssertFalse(application.buttons["Lanjut dan masukkan PIN"].exists)
        application.buttons["Ringkasan Produk dan Layanan Asuransi Reksa Dana Berjangka"].tap()
        XCTAssertFalse(application.buttons["Lanjut dan masukkan PIN"].exists)
        let terms = application.buttons["Syarat & Ketentuan"]
        reveal(terms)
        terms.tap()
        let next = application.buttons["Lanjut dan masukkan PIN"]
        reveal(next)
        next.tap()
        XCTAssertEqual(application.staticTexts["preview.feedback"].label, "Callback otorisasi ke host")
        capture("previewbook-documents-accepted")
    }

    private func openPage(_ entry: String) {
        let row = application.descendants(matching: .any)["preview.component.\(entry)"].firstMatch
        reveal(row)
        row.tap()
        XCTAssertTrue(
            application.descendants(matching: .any)["preview.page.\(entry)"].firstMatch
                .waitForExistence(timeout: 5))
    }

    private func reveal(_ element: XCUIElement) {
        for _ in 0..<8 {
            if element.exists && element.isHittable { return }
            application.swipeUp()
        }
        XCTAssertTrue(element.exists && element.isHittable)
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: application.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
