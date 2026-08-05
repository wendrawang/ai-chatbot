import UIKit

public struct TanyaAITheme {
    public let colors: TanyaAIColors
    public let fonts: TanyaAIFonts

    public init(colors: TanyaAIColors, fonts: TanyaAIFonts) {
        self.colors = colors
        self.fonts = fonts
    }
}

public extension TanyaAITheme {
    static var sandbox: TanyaAITheme {
        TanyaAITheme(
            colors: sandboxColors,
            fonts: sandboxFonts
        )
    }

    private static var sandboxColors: TanyaAIColors {
        TanyaAIColors(
            background: .systemBackground,
            surface: .secondarySystemBackground,
            primaryText: .label,
            secondaryText: .secondaryLabel,
            accent: UIColor(red: 0.58, green: 0.04, blue: 0.12, alpha: 1),
            userBubble: UIColor(red: 0.51, green: 0.04, blue: 0.12, alpha: 1),
            userBubbleText: .white,
            assistantBubble: .secondarySystemBackground,
            assistantBubbleText: .label,
            divider: .separator,
            chartTrack: .tertiarySystemFill,
            chartColors: [
                UIColor(red: 0.83, green: 0.04, blue: 0.16, alpha: 1),
                UIColor(red: 0.91, green: 0.55, blue: 0.03, alpha: 1),
                UIColor(red: 0.04, green: 0.47, blue: 0.77, alpha: 1),
                UIColor(red: 0.05, green: 0.58, blue: 0.30, alpha: 1),
                .systemGray
            ],
            success: .systemGreen,
            warning: .systemOrange,
            error: .systemRed,
            overlay: UIColor.black.withAlphaComponent(0.45)
        )
    }

    private static var sandboxFonts: TanyaAIFonts {
        TanyaAIFonts(
            title: scaledFont(style: .title1, weight: .bold),
            headline: scaledFont(style: .headline, weight: .semibold),
            body: scaledFont(style: .body, weight: .regular),
            subheadline: scaledFont(style: .subheadline, weight: .regular),
            footnote: scaledFont(style: .footnote, weight: .regular),
            caption: scaledFont(style: .caption1, weight: .regular),
            amount: scaledFont(style: .title2, weight: .bold),
            button: scaledFont(style: .headline, weight: .semibold)
        )
    }

    private static func scaledFont(
        style: UIFont.TextStyle,
        weight: UIFont.Weight
    ) -> UIFont {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(
            withTextStyle: style
        )
        let baseFont = UIFont.systemFont(
            ofSize: descriptor.pointSize,
            weight: weight
        )
        return UIFontMetrics(forTextStyle: style).scaledFont(for: baseFont)
    }
}
