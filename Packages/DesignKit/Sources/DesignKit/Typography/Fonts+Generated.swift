import UIKit

public extension Fonts {
    /// Register bundled fonts first. The theme modifier resolves these recipes for each container.
    static func branded(compatibleWith traits: UITraitCollection? = nil) -> Fonts {
        let fonts = Fonts(
            title: brandedFont(.firaBold, FigmaSize.typographySizeHeadingLarge32, .title1),
            headline: brandedFont(.firaSemibold, FigmaSize.typographySizeHeadingSmall20, .headline),
            body: brandedFont(.openRegular, FigmaSize.typographySizeDisplayNormal16, .body),
            subheadline: brandedFont(.openRegular, FigmaSize.typographySizeDisplaySmall14, .subheadline),
            footnote: brandedFont(.openRegular, FigmaSize.typographySizeDisplayTiny12, .footnote),
            caption: brandedFont(.openRegular, FigmaSize.typographySizeDisplayTiny12, .caption1),
            amount: brandedFont(.firaBold, FigmaSize.typographySizeHeadingMedium24, .title2),
            button: brandedFont(.firaMedium, FigmaSize.typographySizeButton16, .headline)
        )
        return fonts.resolved(artwork: ArtworkMetrics(), traits: traits ?? .current)
    }

    private static func brandedLineHeight(_ style: UIFont.TextStyle) -> CGFloat {
        switch style {
        case .title1: return FigmaSize.typographyLineHeightHeadingLarge32
        case .title2: return FigmaSize.typographyLineHeightHeadingMedium24
        case .headline: return FigmaSize.typographyLineHeightHeadingSmall20
        case .subheadline: return FigmaSize.typographyLineHeightDisplaySmall14
        case .footnote, .caption1: return FigmaSize.typographyLineHeightDisplayTiny12
        default: return FigmaSize.typographyLineHeightDisplayNormal16
        }
    }

    private static func brandedFont(
        _ face: DesignKitFont,
        _ size: CGFloat,
        _ style: UIFont.TextStyle
    ) -> DesignKitTypography {
        DesignKitTypography(
            postScriptName: face.postScriptName, size: size, style: style,
            lineHeight: face == .firaMedium ? FigmaSize.typographyLineHeightButton16 : brandedLineHeight(style)
        )
    }
}
