//
//  BottomSheetUITests.swift
//  TanyaAISandboxUITests
//
//  Created by Wendra on 12/11/26.
//

import XCTest

/// `--sheet-demo`: bottom sheet contoh di atas halaman Tanya AI. Sheet menempel di bawah, setinggi isinya, menutupi
/// header dengan latar gelap, dan menutup lewat ketuk di luar, geser ke bawah, atau pilihan di dalamnya.
/// `--with-history` membuat tombol contoh langsung tampak di ujung daftar.
final class BottomSheetUITests: XCTestCase {
    private let application = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testSheetSitsAtTheBottomAsTallAsItsContent() {
        let sheet = openSheet()
        let screen = application.frame
        let options = application.buttons.matching(identifier: "sandbox.sheet.option")
        XCTAssertEqual(options.count, 4)
        // Permukaan sheet sampai ke tepi bawah layar, sedangkan isinya berhenti sebelum home indicator.
        XCTAssertGreaterThanOrEqual(sheet.frame.maxY, screen.maxY)
        XCTAssertLessThan(options.element(boundBy: 3).frame.maxY, screen.maxY - 30)
        XCTAssertEqual(sheet.frame.width, screen.width, accuracy: 1)
        XCTAssertGreaterThan(sheet.frame.minY, screen.midY, "empat baris contoh tidak sampai setengah layar")
        XCTAssertEqual(application.buttons["sheet.handle"].label, "Close sheet")
        capture("bottom-sheet-open")
    }

    /// Latar gelap menutupi header juga: ketukan di posisi tombol kembali menutup sheet, bukan keluar dari halaman.
    func testTappingOutsideClosesTheSheetEvenOverTheHeader() {
        let sheet = openSheet()
        application.buttons["header.back"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        waitUntilGone(sheet)
        XCTAssertTrue(application.buttons["sandbox.sheet.open"].exists, "halaman Tanya AI masih terbuka")
    }

    func testDraggingDownClosesTheSheetAndAShortDragDoesNot() {
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
        let sheet = openSheet()
        application.buttons.matching(identifier: "sandbox.sheet.option").firstMatch.tap()
        waitUntilGone(sheet)
    }
}

// MARK: - Helpers

private extension BottomSheetUITests {
    func openSheet() -> XCUIElement {
        application.launchArguments = ["--language", "en", "--sheet-demo", "--with-history"]
        application.launch()
        let entry = application.buttons["sandbox.open"]
        XCTAssertTrue(entry.waitForExistence(timeout: 10))
        entry.tap()
        let open = application.buttons["sandbox.sheet.open"]
        XCTAssertTrue(open.waitForExistence(timeout: 10))
        open.tap()
        // Sheet membawa trait modal, jadi XCUITest melaporkannya sebagai alert, bukan elemen biasa.
        let sheet = application.descendants(matching: .any)["sheet"]
        XCTAssertTrue(sheet.waitForExistence(timeout: 5))
        return sheet
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
