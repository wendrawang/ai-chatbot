import DesignKit
import TanyaAI
import UIKit

/// Maps the host design system into the feature.
///
/// The package's design system takes `UIColor` and `UIFont` on this branch,
/// so host tokens usually pass straight through. The package never imports
/// the host design system.
extension TanyaAITheme {
    static var host: TanyaAITheme {
        TanyaAITheme(colors: hostColors, fonts: hostFonts)
    }

    private static var hostColors: TanyaAIColors {
        let fallback = TanyaAITheme.sandbox.colors
        return TanyaAIColors(
            background: UIColor(named: "Background") ?? fallback.background,
            surface: UIColor(named: "Surface") ?? fallback.surface,
            primaryText: UIColor(named: "TextPrimary") ?? fallback.primaryText,
            secondaryText: UIColor(named: "TextSecondary") ?? fallback.secondaryText,
            accent: UIColor(named: "Accent") ?? fallback.accent,
            userBubble: UIColor(named: "BubbleOutgoing") ?? fallback.userBubble,
            userBubbleText: UIColor(named: "OnAccent") ?? fallback.userBubbleText,
            assistantBubble: UIColor(named: "BubbleIncoming") ?? fallback.assistantBubble,
            assistantBubbleText: UIColor(named: "TextPrimary") ?? fallback.primaryText,
            divider: UIColor(named: "Divider") ?? fallback.divider,
            chartTrack: UIColor(named: "ChartTrack") ?? fallback.chartTrack,
            chartColors: [
                UIColor(named: "ChartSeries1") ?? fallback.chartColors[0],
                UIColor(named: "ChartSeries2") ?? fallback.chartColors[1],
                UIColor(named: "ChartSeries3") ?? fallback.chartColors[2],
                UIColor(named: "ChartSeries4") ?? fallback.chartColors[3],
                UIColor(named: "ChartSeries5") ?? fallback.chartColors[4]
            ],
            success: UIColor(named: "Success") ?? fallback.success,
            warning: UIColor(named: "Warning") ?? fallback.warning,
            error: UIColor(named: "Error") ?? fallback.error,
            overlay: UIColor(named: "Overlay") ?? fallback.overlay
        )
    }

    private static var hostFonts: TanyaAIFonts {
        TanyaAIFonts(
            title: hostFont(
                "HostSans-Bold", FigmaSize.typographySizeHeadingLarge32, .title1,
                FigmaSize.typographyLineHeightHeadingLarge32, .bold),
            headline: hostFont(
                "HostSans-Semibold", FigmaSize.typographySizeHeadingSmall20, .headline,
                FigmaSize.typographyLineHeightHeadingSmall20, .semibold),
            body: hostFont(
                "HostSans-Regular", FigmaSize.typographySizeDisplayNormal16, .body,
                FigmaSize.typographyLineHeightDisplayNormal16),
            subheadline: hostFont(
                "HostSans-Regular", FigmaSize.typographySizeDisplaySmall14, .subheadline,
                FigmaSize.typographyLineHeightDisplaySmall14),
            footnote: hostFont(
                "HostSans-Regular", FigmaSize.typographySizeDisplayTiny12, .footnote,
                FigmaSize.typographyLineHeightDisplayTiny12),
            caption: hostFont(
                "HostSans-Regular", FigmaSize.typographySizeDisplayTiny12, .caption1,
                FigmaSize.typographyLineHeightDisplayTiny12),
            amount: hostFont(
                "HostSans-Bold", FigmaSize.typographySizeHeadingMedium24, .title2,
                FigmaSize.typographyLineHeightHeadingMedium24, .bold),
            button: hostFont(
                "HostSans-Semibold", FigmaSize.typographySizeButton16, .headline,
                FigmaSize.typographyLineHeightButton16, .semibold)
        )
    }

    private static func hostFont(
        _ name: String, _ size: CGFloat, _ style: UIFont.TextStyle,
        _ lineHeight: CGFloat, _ weight: UIFont.Weight = .regular
    ) -> DesignKitTypography {
        DesignKitTypography(
            postScriptName: name, size: size, style: style,
            fallbackWeight: weight, lineHeight: lineHeight)
    }
}
