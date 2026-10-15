//
//  FontTests.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import CoreText
import UIKit
import XCTest

@testable import DesignKit

final class FontTests: XCTestCase {
    func testBundledFontsRegisterWithTheirRealPostScriptNames() throws {
        try FontFace.registerFonts()
        try FontFace.registerFonts()
        let expected: [(FontFace, String)] = [
            (.firaSansRegular, "FiraSans-Regular"), (.firaSansMedium, "FiraSans-Medium"),
            (.firaSansSemiBold, "FiraSans-SemiBold"), (.firaSansBold, "FiraSans-Bold"),
            (.openSansRegular, "OpenSansRoman-Regular"), (.openSansMedium, "OpenSansRoman-Medium"),
            (.openSansBold, "OpenSans-Bold")
        ]
        XCTAssertEqual(Set(FontFace.allCases), Set(expected.map(\.0)))
        for (face, postScriptName) in expected {
            XCTAssertEqual(face.postScriptName, postScriptName)
            XCTAssertEqual(face.font(size: 16).fontName, postScriptName)
            let font = try XCTUnwrap(UIFont(name: postScriptName, size: 16))
            XCTAssertEqual(font.fontName, postScriptName)
        }
    }

    func testChineseUsesRealFallbackGlyphsRatherThanMissingGlyphBoxes() throws {
        try FontFace.registerFonts()
        for face in FontFace.allCases {
            let text = NSAttributedString(string: "你好，世界", attributes: [.font: face.font(size: 16)])
            let line = CTLineCreateWithAttributedString(text as CFAttributedString)
            let runs = CTLineGetGlyphRuns(line) as? [CTRun] ?? []
            XCTAssertFalse(runs.isEmpty, face.rawValue)
            for run in runs {
                var glyphs = Array(repeating: CGGlyph(0), count: CTRunGetGlyphCount(run))
                CTRunGetGlyphs(run, CFRange(location: 0, length: 0), &glyphs)
                XCTAssertFalse(glyphs.contains(0), face.rawValue)
            }
        }
    }
}
