//
//  ArtworkSizingTests.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import UIKit
import XCTest

@testable import DesignKit

final class ArtworkSizingTests: XCTestCase {
    func testUncappedHostFormulaAcrossDeviceWidths() {
        for width: CGFloat in [320, 375, 390, 430, 768, 1_024] {
            for value: CGFloat in [0, 0.5, 2, 8, 16, 24, 44] {
                XCTAssertEqual(value.scaledToArtwork(ratio: 375 / width), (value * width / 375).rounded())
            }
        }
    }

    func testScreenAndAccessibilityBoundsNeedNoRootSetup() {
        XCTAssertEqual(CGFloat(16).scaledToArtwork, (16 / (375 / UIScreen.main.bounds.width)).rounded())
        XCTAssertGreaterThanOrEqual(CGFloat(24).tapTargetInArtwork, 44)
        XCTAssertGreaterThanOrEqual(CGFloat(0.1).strokeInArtwork, 1 / UIScreen.main.scale)
        XCTAssertEqual(CGFloat.nan.scaledToArtwork, 0)
        XCTAssertEqual(CGFloat.infinity.scaledToArtwork, 0)
        XCTAssertEqual(CGFloat(16).scaledToArtwork(ratio: 0), 0)
    }
}
