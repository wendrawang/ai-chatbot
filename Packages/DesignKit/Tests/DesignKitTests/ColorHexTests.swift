//
//  ColorHexTests.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import SwiftUI
import XCTest

@testable import DesignKit

final class ColorHexTests: XCTestCase {
    func testRGBFormsAndARGBAlpha() {
        assertComponents(Color(hex: " #3aF "), red: 51 / 255, green: 170 / 255, blue: 1, alpha: 1)
        assertComponents(Color(hex: "336699"), red: 51 / 255, green: 102 / 255, blue: 153 / 255, alpha: 1)
        assertComponents(Color(hex: "80336699"), red: 51 / 255, green: 102 / 255, blue: 153 / 255, alpha: 128 / 255)
    }

    func testMalformedStringsUseTheRequestedFallback() {
        for text in ["", "##FFF", "+FFF", "12", "12345", "GGGGGG", "FFFFFFoops", "ＦＦＦ"] {
            XCTAssertEqual(UIColor(Color(hex: text, fallback: .red)), UIColor(Color.red), text)
        }
        assertComponents(Color(hex: "invalid"), red: 0, green: 0, blue: 0, alpha: 0)
    }

    private func assertComponents(_ color: Color, red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var actualRed: CGFloat = 0
        var actualGreen: CGFloat = 0
        var actualBlue: CGFloat = 0
        var actualAlpha: CGFloat = 0
        XCTAssertTrue(UIColor(color).getRed(&actualRed, green: &actualGreen, blue: &actualBlue, alpha: &actualAlpha))
        XCTAssertEqual(actualRed, red, accuracy: 0.001)
        XCTAssertEqual(actualGreen, green, accuracy: 0.001)
        XCTAssertEqual(actualBlue, blue, accuracy: 0.001)
        XCTAssertEqual(actualAlpha, alpha, accuracy: 0.001)
    }
}
