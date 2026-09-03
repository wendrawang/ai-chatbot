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
        TanyaAIColors(
            background: UIColor(named: "Background")!,
            surface: UIColor(named: "Surface")!,
            primaryText: UIColor(named: "TextPrimary")!,
            secondaryText: UIColor(named: "TextSecondary")!,
            accent: UIColor(named: "Accent")!,
            userBubble: UIColor(named: "BubbleOutgoing")!,
            userBubbleText: UIColor(named: "OnAccent")!,
            assistantBubble: UIColor(named: "BubbleIncoming")!,
            assistantBubbleText: UIColor(named: "TextPrimary")!,
            divider: UIColor(named: "Divider")!,
            chartTrack: UIColor(named: "ChartTrack")!,
            chartColors: [
                UIColor(named: "ChartSeries1")!,
                UIColor(named: "ChartSeries2")!,
                UIColor(named: "ChartSeries3")!,
                UIColor(named: "ChartSeries4")!,
                UIColor(named: "ChartSeries5")!
            ],
            success: UIColor(named: "Success")!,
            warning: UIColor(named: "Warning")!,
            error: UIColor(named: "Error")!,
            overlay: UIColor.black.withAlphaComponent(0.45)
        )
    }

    private static var hostFonts: TanyaAIFonts {
        TanyaAIFonts(
            title: UIFont(name: "HostSans-Bold", size: 28)!,
            headline: UIFont(name: "HostSans-Semibold", size: 17)!,
            body: UIFont(name: "HostSans-Regular", size: 17)!,
            subheadline: UIFont(name: "HostSans-Regular", size: 15)!,
            footnote: UIFont(name: "HostSans-Regular", size: 13)!,
            caption: UIFont(name: "HostSans-Regular", size: 12)!,
            amount: UIFont(name: "HostSans-Bold", size: 22)!,
            button: UIFont(name: "HostSans-Semibold", size: 17)!
        )
    }
}
