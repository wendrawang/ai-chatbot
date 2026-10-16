//
//  PrototypeFlowUITests.swift
//  TanyaAISandboxUITests
//
//  Created by Wendra on 16/10/26.
//

import XCTest

final class PrototypeFlowUITests: XCTestCase
{
    func testCompleteTransferAndRetainedReceipt()
    {
        let app = launch(language: "en", scenario: "success")
        tap("Transfer BI FAST", app: app)
        tap("Continue", app: app)
        tap("Confirm transfer", app: app)
        for digit in [1, 2, 3, 4, 5, 6]
        {
            tap(String(digit), app: app)
        }

        XCTAssertTrue(app.staticTexts["Simulated transfer successful"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["DEMO-intent-1-flow-quote-0"].exists)
        attach(app, name: "receipt-en")
    }

    func testPendingNeedsStatusCheck()
    {
        let app = launch(language: "id", scenario: "pending")
        tap("Transfer BI FAST", app: app)
        tap("Lanjut", app: app)
        tap("Konfirmasi", app: app)
        for digit in [9, 8, 7, 6, 5, 4]
        {
            tap(String(digit), app: app)
        }

        tap("Periksa Status", app: app)
        XCTAssertTrue(app.staticTexts["Simulasi transfer berhasil"].waitForExistence(timeout: 5))
        attach(app, name: "receipt-id-pending")
    }

    func testChineseComposerCapsAtFourLines()
    {
        let app = launch(language: "zh-Hans", scenario: "success")
        let field = app.textViews["询问财务与 OCBC 服务…"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("line one\nline two\nline three\nline four")
        let fourLineHeight = field.frame.height
        field.typeText("\nline five\nline six\nline seven")
        XCTAssertEqual(field.frame.height, fourLineHeight, accuracy: 1)
        attach(app, name: "composer-zh-four-lines")
    }

    private func launch(language: String, scenario: String) -> XCUIApplication
    {
        let app = XCUIApplication()
        app.launchArguments = ["--chat", "--language", language, "--scenario", scenario]
        app.launch()
        return app
    }

    private func tap(_ label: String, app: XCUIApplication)
    {
        let button = app.buttons[label].firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 5), label)
        for _ in 0 ..< 12
        {
            guard !button.isHittable
            else
            {
                button.tap()
                return
            }

            app.tables.firstMatch.swipeUp()
        }

        XCTFail("Button unreachable: " + label)
    }

    private func attach(_ app: XCUIApplication, name: String)
    {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
