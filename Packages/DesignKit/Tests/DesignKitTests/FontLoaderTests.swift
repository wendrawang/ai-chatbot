import UIKit
import XCTest
@testable import DesignKit

final class FontLoaderTests: XCTestCase {
    func testBundledFontsRegisterWithExpectedNames() throws {
        try DesignKitFont.registerFonts()
        try DesignKitFont.registerFonts()

        for face in DesignKitFont.allCases {
            XCTAssertNotNil(UIFont(name: face.postScriptName, size: 16), face.postScriptName)
        }
        let fonts = Fonts.branded()
        XCTAssertEqual(fonts.body.fontName, DesignKitFont.openRegular.postScriptName)
        XCTAssertEqual(fonts.title.fontName, DesignKitFont.firaBold.postScriptName)
    }

    func testCustomFontScalesWithContentSizeCategory() throws {
        try DesignKitFont.registerFonts()
        let typography = DesignKitTypography(
            postScriptName: DesignKitFont.openRegular.postScriptName,
            size: FigmaSize.typographySizeDisplayNormal16,
            style: .body
        )
        let regular = typography.font(compatibleWith: UITraitCollection(preferredContentSizeCategory: .large))
        let enlarged = typography.font(compatibleWith: UITraitCollection(
            preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge
        ))

        XCTAssertGreaterThan(enlarged.pointSize, regular.pointSize)
        XCTAssertEqual(enlarged.fontName, regular.fontName)
    }

    func testMissingFontFailsExplicitly() {
        XCTAssertThrowsError(try FontLoader.register(
            fileNames: ["Missing.ttf"], bundle: Bundle(for: Self.self)
        ))
        XCTAssertThrowsError(try FontLoader.register(url: URL(fileURLWithPath: "/missing.ttf")))
    }

    func testUnknownFaceUsesSystemFallback() {
        let typography = DesignKitTypography(postScriptName: "MissingFace", size: 16, style: .body)
        XCTAssertFalse(typography.font().fontName.isEmpty)
    }
}
