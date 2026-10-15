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
        XCTAssertEqual(FontFace.regular.font(size: 16).fontName, "OpenSansRoman-Regular")
        XCTAssertEqual(FontFace.medium.font(size: 16).fontName, "OpenSansRoman-Medium")
    }

    func testChineseUsesRealFallbackGlyphsRatherThanMissingGlyphBoxes() throws {
        try FontFace.registerFonts()
        let text = NSAttributedString(string: "你好，世界", attributes: [.font: FontFace.regular.font(size: 16)])
        let line = CTLineCreateWithAttributedString(text as CFAttributedString)
        let runs = CTLineGetGlyphRuns(line) as? [CTRun] ?? []
        XCTAssertFalse(runs.isEmpty)
        for run in runs {
            var glyphs = Array(repeating: CGGlyph(0), count: CTRunGetGlyphCount(run))
            CTRunGetGlyphs(run, CFRange(location: 0, length: 0), &glyphs)
            XCTAssertFalse(glyphs.contains(0))
        }
    }
}
