import UIKit

public extension Fonts {
    /// Register bundled fonts first. Recreate when UIKit's content-size category changes.
    static func branded(compatibleWith traits: UITraitCollection? = nil) -> Fonts {
        Fonts(
            title: brandedFont(.firaBold, FigmaSize.typographySizeHeadingLarge32, .title1, traits),
            headline: brandedFont(.firaSemibold, FigmaSize.typographySizeHeadingSmall20, .headline, traits),
            body: brandedFont(.openRegular, FigmaSize.typographySizeDisplayNormal16, .body, traits),
            subheadline: brandedFont(.openRegular, FigmaSize.typographySizeDisplaySmall14, .subheadline, traits),
            footnote: brandedFont(.openRegular, FigmaSize.typographySizeDisplayTiny12, .footnote, traits),
            caption: brandedFont(.openRegular, FigmaSize.typographySizeDisplayTiny12, .caption1, traits),
            amount: brandedFont(.firaBold, FigmaSize.typographySizeHeadingMedium24, .title2, traits),
            button: brandedFont(.firaMedium, FigmaSize.typographySizeButton16, .headline, traits)
        )
    }

    private static func brandedFont(
        _ face: DesignKitFont,
        _ size: CGFloat,
        _ style: UIFont.TextStyle,
        _ traits: UITraitCollection?
    ) -> UIFont {
        DesignKitTypography(postScriptName: face.postScriptName, size: size, style: style)
            .font(compatibleWith: traits)
    }
}
