import XCTest

final class TanyaAIAnswerUITests: XCTestCase {
    func testRadioBecomesPromptAndOnlyOptionsDisappear() {
        let application = XCUIApplication()
        application.launchArguments = ["--answers"]
        application.launch()
        let option = application.buttons["option.product"]
        XCTAssertTrue(option.waitForExistence(timeout: 10))
        let table = application.tables["chat.messageTable"]
        for _ in 0..<4 where option.isHittable == false { table.swipeDown() }
        XCTAssertTrue(option.isHittable)
        capture("answer-before-selection")
        option.tap()
        XCTAssertTrue(application.staticTexts["Pilihan diterima."].waitForExistence(timeout: 5))
        XCTAssertFalse(application.buttons["option.product"].exists)
        XCTAssertFalse(application.buttons["option.support"].exists)
        XCTAssertTrue(application.staticTexts["Informasi produk"].exists)
        XCTAssertTrue(application.staticTexts["Pilih informasi yang ingin Anda lihat."].exists)
        XCTAssertTrue(application.staticTexts["Promo produk pilihan"].exists)
        XCTAssertTrue(application.buttons["action.product"].exists)
        capture("answer-after-selection")
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
