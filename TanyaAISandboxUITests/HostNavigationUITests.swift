//
//  HostNavigationUITests.swift
//  TanyaAISandboxUITests
//
//  Created by Wendra on 20/10/26.
//

import XCTest

/// Host tiruan SwiftUI: Tanya AI dibuka dari halaman mana pun dan blocker host tampil di atasnya.
final class HostNavigationUITests: XCTestCase {
    private let application = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testOpensFromDetailPageAndBackReturnsToDetail() {
        launch()
        application.buttons["sandbox.detail.open"].tap()
        let openFromDetail = application.buttons["sandbox.detail.tanyaAI"]
        XCTAssertTrue(openFromDetail.waitForExistence(timeout: 5))
        openFromDetail.tap()
        XCTAssertTrue(application.textViews["composer.input"].waitForExistence(timeout: 10))
        let back = application.buttons.matching(identifier: "header.back").allElementsBoundByIndex.first {
            $0.isHittable
        }
        back?.tap()
        XCTAssertTrue(openFromDetail.waitForExistence(timeout: 5))
        XCTAssertTrue(openFromDetail.isHittable)
        XCTAssertFalse(application.textViews["composer.input"].exists)
    }

    func testOfflineBlockerCoversTanyaAIAndTheChatOffersRetry() {
        launch(extra: ["--offline"])
        application.buttons["sandbox.open"].tap()
        // Init sesi gagal: blocker host tampil di atas Tanya AI.
        let blockerRetry = application.buttons["sandbox.offline.retry"]
        XCTAssertTrue(blockerRetry.waitForExistence(timeout: 10))
        blockerRetry.tap()
        // Setelah blocker ditutup, chat menampilkan status putus dengan tombol coba lagi.
        XCTAssertTrue(application.buttons["chat.retry"].waitForExistence(timeout: 5))
        XCTAssertTrue(application.textViews["composer.input"].isHittable)
        XCTAssertFalse(application.buttons["composer.send"].isEnabled)
    }

    func testLogoutAndLoginReturnToMain() {
        launch()
        application.buttons["sandbox.logout"].tap()
        let login = application.buttons["sandbox.login"]
        XCTAssertTrue(login.waitForExistence(timeout: 5))
        login.tap()
        XCTAssertTrue(application.buttons["sandbox.open"].waitForExistence(timeout: 5))
    }

    private func launch(extra: [String] = []) {
        application.launchArguments = ["--language", "en", "--terms-accepted"] + extra
        application.launch()
        XCTAssertTrue(application.buttons["sandbox.open"].waitForExistence(timeout: 10))
    }
}
