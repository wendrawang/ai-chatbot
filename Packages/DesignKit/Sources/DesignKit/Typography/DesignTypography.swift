//
//  DesignTypography.swift
//  DesignKit
//
//  Created by Wendra on 16/10/26.
//

import SwiftUI
import UIKit

public enum DesignTypography
{
    public static func body(_ traits: UITraitCollection? = nil) -> UIFont
    {
        scaled(.openRegular, size: FigmaSize.typographySizeDisplaySmall14, style: .body, traits: traits)
    }

    public static func heading(_ traits: UITraitCollection? = nil) -> UIFont
    {
        scaled(.firaSemibold, size: FigmaSize.typographySizeHeadingSmall20, style: .headline, traits: traits)
    }

    public static func amount(_ traits: UITraitCollection? = nil) -> UIFont
    {
        scaled(.firaBold, size: FigmaSize.typographySizeHeadingLarge32, style: .title1, traits: traits)
    }

    public static var composer: UIFont
    {
        FontLoader.registerFonts()
        return UIFont(name: FontFace.firaRegular.rawValue, size: FigmaSize.typographySizeDisplaySmall14)
            ?? .systemFont(ofSize: FigmaSize.typographySizeDisplaySmall14)
    }

    private static func scaled(
        _ face: FontFace, size: CGFloat, style: UIFont.TextStyle, traits: UITraitCollection?) -> UIFont
    {
        FontLoader.registerFonts()
        let base = UIFont(name: face.rawValue, size: size) ?? .systemFont(ofSize: size)
        return UIFontMetrics(forTextStyle: style).scaledFont(for: base, compatibleWith: traits)
    }
}
