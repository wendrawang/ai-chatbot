//
//  FontLineHeightTests.swift
//  DesignKit
//
//  Created by Wendra on 27/10/26.
//

import Testing
import UIKit

@testable import DesignKit

struct FontLineHeightTests {
    /// Tinggi baris font + jarak tambahan = token line-height pasangannya.
    @Test(arguments: [
        (FigmaSize.typographySizeDisplayTiny12, FigmaSize.typographyLineHeightDisplayTiny12),
        (FigmaSize.typographySizeDisplaySmall14, FigmaSize.typographyLineHeightDisplaySmall14),
        (FigmaSize.typographySizeHeadingSmall20, FigmaSize.typographyLineHeightHeadingSmall20)
    ])
    func spacingFillsTheGapToTheFigmaLineHeight(size: CGFloat, lineHeight: CGFloat) throws {
        try FontFace.registerFonts()
        let font = FontFace.openSansRegular.font(size: size)
        let spacing = font.lineSpacing(forLineHeight: lineHeight)
        #expect(spacing > .zero)
        #expect(abs(font.lineHeight + spacing - lineHeight) < 0.001)
    }

    @Test
    func lineHeightShorterThanTheFontAddsNoSpacing() {
        let font = FontFace.openSansRegular.font(size: FigmaSize.typographySizeHeadingSmall20)
        #expect(font.lineSpacing(forLineHeight: font.lineHeight / 2) == .zero)
    }
}
