//
//  TypographyTests.swift
//  DesignKit
//
//  Created by Wendra on 18/10/26.
//

import SwiftUI
import XCTest

@testable import DesignKit

@MainActor
final class TypographyTests: XCTestCase {
    func testRolesUseNamedFigmaTokensAndBundledFaces() throws {
        try FontFace.registerFonts()
        XCTAssertEqual(DesignTextStyle.body.face, .openSansRegular)
        XCTAssertEqual(DesignTextStyle.body.size, FigmaSize.typographySizeDisplaySmall14)
        XCTAssertEqual(DesignTextStyle.body.lineHeight, FigmaSize.typographyLineHeightDisplaySmall14)
        XCTAssertEqual(DesignTextStyle.screenTitle.face, .firaSansSemiBold)
        XCTAssertEqual(DesignTextStyle.screenTitle.size, FigmaSize.typographySizeDisplayNormal16)
        for style in [DesignTextStyle.body, .screenTitle] {
            XCTAssertEqual(style.uiFont.fontName, style.face.postScriptName)
            XCTAssertEqual(style.uiFont.pointSize, style.size.scaledToArtwork)
        }
    }

    func testLineSpacingFillsTheFigmaLineHeightWithoutGoingNegative() throws {
        try FontFace.registerFonts()
        let body = DesignTextStyle.body
        XCTAssertEqual(body.uiFont.lineHeight + body.lineSpacing, body.lineHeight.scaledToArtwork, accuracy: 0.01)
        let tight = DesignTextStyle(face: .openSansRegular, size: 14, lineHeight: 1)
        XCTAssertEqual(tight.lineSpacing, .zero)
    }
}
