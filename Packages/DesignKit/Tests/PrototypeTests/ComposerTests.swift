//
//  ComposerTests.swift
//  DesignKitTests
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import XCTest

final class ComposerTests: XCTestCase
{
    func testComposerLimitsAndBundledFonts()
    {
        FontLoader.registerFonts()
        XCTAssertEqual(CustomSizes.maximumInputLines, 4)
        XCTAssertEqual(DesignTypography.composer.pointSize, FigmaSize.typographySizeDisplaySmall14)
        for face in FontFace.allCases
        {
            XCTAssertNotNil(UIFont(name: face.rawValue, size: 14))
        }
    }
}
