//
//  FontTests.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import CoreText
import Testing
import UIKit

@testable import DesignKit

struct FontTests {
    @Test
    func bundledFontsRegisterWithTheirRealPostScriptNames() throws {
        try FontFace.registerFonts()
        try FontFace.registerFonts()
        let expected: [(FontFace, String)] = [
            (.firaSansRegular, "FiraSans-Regular"), (.firaSansMedium, "FiraSans-Medium"),
            (.firaSansSemiBold, "FiraSans-SemiBold"), (.firaSansBold, "FiraSans-Bold"),
            (.openSansRegular, "OpenSansRoman-Regular"), (.openSansMedium, "OpenSansRoman-Medium"),
            (.openSansBold, "OpenSans-Bold")
        ]
        #expect(Set(FontFace.allCases) == Set(expected.map(\.0)))
        for (face, postScriptName) in expected {
            #expect(face.postScriptName == postScriptName)
            #expect(face.font(size: 16).fontName == postScriptName)
            let font = try #require(UIFont(name: postScriptName, size: 16))
            #expect(font.fontName == postScriptName)
        }
    }

    @Test
    func chineseUsesRealFallbackGlyphsRatherThanMissingGlyphBoxes() throws {
        try FontFace.registerFonts()
        for face in FontFace.allCases {
            let text = NSAttributedString(string: "你好，世界", attributes: [.font: face.font(size: 16)])
            let line = CTLineCreateWithAttributedString(text as CFAttributedString)
            let runs = CTLineGetGlyphRuns(line) as? [CTRun] ?? []
            #expect(!runs.isEmpty, "\(face.rawValue)")
            for run in runs {
                var glyphs = Array(repeating: CGGlyph(0), count: CTRunGetGlyphCount(run))
                CTRunGetGlyphs(run, CFRange(location: 0, length: 0), &glyphs)
                #expect(!glyphs.contains(0), "\(face.rawValue)")
            }
        }
    }
}
