import UIKit
import XCTest
@testable import DesignKit

final class TypographyResolutionTests: XCTestCase {
    func testArtworkAndDynamicTypeAreAppliedOnlyOnce() {
        let artwork = ArtworkMetrics(containerSize: CGSize(width: 450, height: 812))
        let traits = UITraitCollection(preferredContentSizeCategory: .accessibilityExtraLarge)
        let initial = Theme.sandbox.fonts
        let first = initial.resolved(artwork: artwork, traits: traits)
        let repeated = first.resolved(artwork: artwork, traits: traits)
        XCTAssertEqual(first.body.pointSize, repeated.body.pointSize)
        XCTAssertEqual(first, repeated)
        let baseline = initial.resolved(artwork: artwork, traits: UITraitCollection(
            preferredContentSizeCategory: .large
        ))
        XCTAssertGreaterThan(first.body.pointSize, baseline.body.pointSize)
    }

    func testResolvingFromLargeContainerBackToReferenceDoesNotCompoundScale() {
        let traits = UITraitCollection(preferredContentSizeCategory: .large)
        let initial = Theme.sandbox.fonts
        let larger = initial.resolved(
            artwork: ArtworkMetrics(containerSize: CGSize(width: 468.75, height: 812)), traits: traits
        )
        let restored = larger.resolved(artwork: ArtworkMetrics(), traits: traits)
        let baseline = initial.resolved(artwork: ArtworkMetrics(), traits: traits)
        XCTAssertEqual(restored.body.pointSize, baseline.body.pointSize)
    }

    func testLineSpacingNeverClipsFontAndFollowsResolvedFontSize() throws {
        try DesignKitFont.registerFonts()
        let fonts = Fonts.branded().resolved(
            artwork: ArtworkMetrics(), traits: UITraitCollection(preferredContentSizeCategory: .large)
        )
        XCTAssertGreaterThanOrEqual(fonts.lineSpacing(for: .body), 0)
        XCTAssertGreaterThanOrEqual(fonts.body.lineHeight + fonts.lineSpacing(for: .body), 24)
    }
}
