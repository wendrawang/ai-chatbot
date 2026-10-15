import UIKit
import XCTest

@testable import DesignKit

final class ArtworkMetricsTests: XCTestCase {
    func testReferenceArtworkKeepsDesignMeasurements() {
        let artwork = ArtworkMetrics()
        XCTAssertEqual(artwork.scale, 1)
        XCTAssertEqual(artwork.size(16), 16)
        XCTAssertEqual(artwork.size(44), 44)
    }

    func testWidthScalingRoundsPointsLikeLegacySizing() {
        let artwork = ArtworkMetrics(containerSize: CGSize(width: 414, height: 896), displayScale: 3)
        XCTAssertEqual(artwork.scale, 414 / 375, accuracy: 0.0001)
        XCTAssertEqual(artwork.size(16), 18)
        let short = ArtworkMetrics(containerSize: CGSize(width: 414, height: 300), displayScale: 3)
        XCTAssertEqual(short.size(16), artwork.size(16))
    }

    func testCustomReferenceAndWideScreensFollowUncappedHostRatio() {
        let custom = ArtworkMetrics(
            containerSize: CGSize(width: 320, height: 812), referenceSize: CGSize(width: 320, height: 812)
        )
        XCTAssertEqual(custom.scale, 1)
        let tablet = ArtworkMetrics(containerSize: CGSize(width: 1_024, height: 768))
        XCTAssertEqual(tablet.scale, 1_024 / 375, accuracy: 0.0001)
        XCTAssertEqual(tablet.size(16), (16 / (375 / CGFloat(1_024))).rounded())
        let wide = ArtworkMetrics(containerSize: CGSize(width: 750, height: 812))
        XCTAssertEqual(wide.scale, 2)
        XCTAssertEqual(wide.size(24), 48)
    }

    func testInvalidGeometryAndMinimumTouchAndStrokeSizes() {
        let invalid = ArtworkMetrics(containerSize: .zero, displayScale: 0)
        XCTAssertEqual(invalid.scale, 1)
        XCTAssertEqual(invalid.size(.nan), 0)
        let narrow = ArtworkMetrics(containerSize: CGSize(width: 200, height: 400), displayScale: 3)
        XCTAssertEqual(narrow.tapTarget(), 44)
        XCTAssertEqual(narrow.stroke(0.1), 1 / 3, accuracy: 0.0001)
        XCTAssertEqual(narrow.stroke(0), 0)
        XCTAssertEqual(narrow.stroke(.infinity), 0)
        XCTAssertLessThan(narrow.size(16), 16)
    }

    func testScreenPropertiesWorkWithoutRootSetup() {
        let current = ArtworkMetrics.screen
        XCTAssertEqual(ArtworkMetrics.referenceSize, CGSize(width: 375, height: 812))
        XCTAssertEqual(current.displayScale, UIScreen.main.scale)
        let expected = (CGFloat(16) / (375 / UIScreen.main.bounds.width)).rounded()
        XCTAssertEqual(CGFloat(16).scaledToArtwork, expected)
        XCTAssertEqual(current.size(16), expected)
        XCTAssertEqual(DesignKitMetrics.Artwork.currentRatio, 375 / UIScreen.main.bounds.width)
        XCTAssertEqual(CGFloat(0.1).strokeInArtwork, current.stroke(0.1))
        XCTAssertGreaterThanOrEqual(CGFloat(32).tapTargetInArtwork, 44)
        XCTAssertEqual(CGFloat.nan.scaledToArtwork, 0)
    }

    func testHostSizingMatchesForPhoneTabletAndLandscapeWidths() {
        for width: CGFloat in [320, 375, 390, 414, 430, 768, 1_024] {
            let artwork = ArtworkMetrics(containerSize: CGSize(width: width, height: 812))
            for value: CGFloat in [0, 0.5, 2, 8, 16, 24, 44] {
                let expected = (value / (375 / width)).rounded()
                XCTAssertEqual(artwork.size(value), expected, "width=\(width), value=\(value)")
            }
        }
    }
}
