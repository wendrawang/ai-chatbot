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
            for value: CGFloat in [0, 0.5, 2, 8, 16, 24, 56] {
                XCTAssertEqual(value.scaledToArtwork(ratio: 375 / width), (value * width / 375).rounded())
            }
        }
    }

    func testScreenScalingUsesDesignValuesWithoutMinimumOverrides() {
        XCTAssertEqual(CGFloat(16).scaledToArtwork, (16 / (375 / UIScreen.main.bounds.width)).rounded())
        XCTAssertEqual(CGFloat(24).scaledToArtwork, (24 / (375 / UIScreen.main.bounds.width)).rounded())
        XCTAssertEqual(CGFloat(0.1).scaledToArtwork(ratio: 1), 0)
        XCTAssertEqual(CGFloat.nan.scaledToArtwork, 0)
        XCTAssertEqual(CGFloat.infinity.scaledToArtwork, 0)
        XCTAssertEqual(CGFloat(16).scaledToArtwork(ratio: 0), 0)
    }
}
