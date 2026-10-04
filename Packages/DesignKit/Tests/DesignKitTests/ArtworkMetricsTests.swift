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
        XCTAssertEqual(artwork.scale, 414 / 374, accuracy: 0.0001)
        XCTAssertEqual(artwork.size(16), 18)
        let short = ArtworkMetrics(containerSize: CGSize(width: 414, height: 300), displayScale: 3)
        XCTAssertEqual(short.size(16), artwork.size(16))
    }

    func testCustomReferenceAndTabletCap() {
        let custom = ArtworkMetrics(
            containerSize: CGSize(width: 374, height: 812), referenceSize: CGSize(width: 374, height: 812)
        )
        XCTAssertEqual(custom.scale, 1)
        let tablet = ArtworkMetrics(containerSize: CGSize(width: 1_024, height: 768))
        XCTAssertEqual(tablet.scale, 1.25)
        let uncapped = ArtworkMetrics(containerSize: CGSize(width: 748, height: 812), maximumScale: 2)
        XCTAssertEqual(uncapped.scale, 2)
    }

    func testInvalidGeometryAndMinimumTouchAndStrokeSizes() {
        let invalid = ArtworkMetrics(containerSize: .zero, displayScale: 0, maximumScale: .nan)
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
        XCTAssertEqual(ArtworkMetrics.referenceSize, CGSize(width: 374, height: 812))
        XCTAssertEqual(current.displayScale, UIScreen.main.scale)
        XCTAssertEqual(CGFloat(16).sizeInArtwork, current.size(16))
        XCTAssertEqual(CGFloat(0.1).strokeInArtwork, current.stroke(0.1))
        XCTAssertGreaterThanOrEqual(CGFloat(32).tapTargetInArtwork, 44)
        XCTAssertEqual(CGFloat.nan.sizeInArtwork, 0)
    }
}
