//
//  BottomSheetUITests.swift
//  TanyaAISandboxUITests
//
//  Created by Wendra on 12/11/26.
//

import XCTest

/// `--sheet-demo`: bottom sheet contoh di atas halaman Tanya AI. Sheet menempel di bawah, setinggi isinya, menutupi
/// header dengan latar gelap, dan menutup lewat ketuk di luar, geser ke bawah, atau pilihan di dalamnya.
/// `--with-history` membuat tombol contoh langsung tampak di ujung daftar. Swipe-back ditahan host selama sheet
/// terbuka.
final class BottomSheetUITests: XCTestCase {
    private let application = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    /// Isi sheet berhenti di atas safe area bawah. Kartu composer juga berhenti padding 16 di atas safe area, jadi
    /// tepi bawahnya menjadi patokan yang benar untuk perangkat dengan maupun tanpa home indicator.
    func testSheetSitsAtTheBottomAsTallAsItsContent() {
        launchDemo()
        let composer = application.otherElements["composer"].frame
        let sheet = openSheet()
        let screen = application.frame
        let options = application.buttons.matching(identifier: "sandbox.sheet.option")
        XCTAssertEqual(options.count, 4)
        XCTAssertGreaterThanOrEqual(sheet.frame.maxY, screen.maxY, "permukaan sheet sampai ke tepi bawah layar")
        XCTAssertEqual(options.element(boundBy: 3).frame.maxY, composer.maxY, accuracy: 1)
        XCTAssertEqual(sheet.frame.width, screen.width, accuracy: 1)
        XCTAssertGreaterThan(sheet.frame.minY, screen.midY, "empat baris contoh tidak sampai setengah layar")
        XCTAssertEqual(application.buttons["sheet.handle"].label, "Close sheet")
        capture("bottom-sheet-open")
    }

    /// Latar gelap menutupi header juga: ketukan di posisi tombol kembali menutup sheet, bukan keluar dari halaman.
    func testTappingOutsideClosesTheSheetEvenOverTheHeader() {
        launchDemo()
        let sheet = openSheet()
        application.buttons["header.back"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        waitUntilGone(sheet)
        XCTAssertTrue(application.buttons["sandbox.sheet.open"].exists, "halaman Tanya AI masih terbuka")
    }

    func testDraggingDownClosesTheSheetAndAShortDragDoesNot() {
        launchDemo()
        let sheet = openSheet()
        let handle = application.buttons["sheet.handle"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        // Ditahan sebelum dilepas supaya tidak terhitung sentakan: sentakan ke bawah memang menutup.
        handle.press(
            forDuration: 0.1,
            thenDragTo: handle.withOffset(CGVector(dx: 0, dy: 20)),
            withVelocity: .slow,
            thenHoldForDuration: 0.5
        )
        XCTAssertTrue(sheet.exists, "geseran pendek mengembalikan sheet")
        handle.press(forDuration: 0.1, thenDragTo: handle.withOffset(CGVector(dx: 0, dy: 240)))
        waitUntilGone(sheet)
    }

    func testChoosingAnOptionClosesTheSheet() {
        launchDemo()
        let sheet = openSheet()
        application.buttons.matching(identifier: "sandbox.sheet.option").firstMatch.tap()
        waitUntilGone(sheet)
    }

    /// Selama sheet terbuka, swipe dari tepi kiri tidak keluar dari halaman; setelah ditutup, swipe-back jalan lagi.
    func testSwipeBackIsHeldWhileTheSheetIsOpen() {
        launchDemo()
        let sheet = openSheet()
        swipeFromLeadingEdge()
        XCTAssertFalse(application.buttons["sandbox.open"].waitForExistence(timeout: 2), "masih di Tanya AI")
        XCTAssertTrue(sheet.exists)
        application.buttons.matching(identifier: "sandbox.sheet.option").firstMatch.tap()
        waitUntilGone(sheet)
        swipeFromLeadingEdge()
        XCTAssertTrue(application.buttons["sandbox.open"].waitForExistence(timeout: 5), "kembali ke halaman host")
    }
}

// MARK: - Helpers

private extension BottomSheetUITests {
    func launchDemo() {
        application.launchArguments = ["--language", "en", "--sheet-demo", "--with-history"]
        application.launch()
        let entry = application.buttons["sandbox.open"]
        XCTAssertTrue(entry.waitForExistence(timeout: 10))
        entry.tap()
    }

    func openSheet() -> XCUIElement {
        let open = application.buttons["sandbox.sheet.open"]
        XCTAssertTrue(open.waitForExistence(timeout: 10))
        open.tap()
        // Sheet membawa trait modal, jadi XCUITest melaporkannya sebagai alert, bukan elemen biasa.
        let sheet = application.descendants(matching: .any)["sheet"]
        XCTAssertTrue(sheet.waitForExistence(timeout: 5))
        return sheet
    }

    /// Sama dengan `StartingPointUITests`: geseran cepat dari tepi kiri sampai hampir ke kanan.
    func swipeFromLeadingEdge() {
        let edge = application.coordinate(withNormalizedOffset: CGVector(dx: 0.005, dy: 0.5))
        edge.press(
            forDuration: 0.05,
            thenDragTo: application.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)),
            withVelocity: .fast,
            thenHoldForDuration: 0
        )
    }

    func waitUntilGone(_ element: XCUIElement) {
        let gone = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: element)
        wait(for: [gone], timeout: 5)
    }

    func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: application.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
