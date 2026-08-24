import SwiftUI
import TanyaAI

/// Maps the host design system into the feature.
///
/// If the existing tokens are `UIColor` and `UIFont`, convert them here with
/// `Color(uiColor:)` and `Font(uiFont)`. The package itself never imports the
/// host design system.
extension TanyaAITheme {
    static var host: TanyaAITheme {
        TanyaAITheme(colors: hostColors, fonts: hostFonts)
    }

    private static var hostColors: TanyaAIColors {
        TanyaAIColors(
            background: Color("Background"),
            surface: Color("Surface"),
            primaryText: Color("TextPrimary"),
            secondaryText: Color("TextSecondary"),
            accent: Color("Accent"),
            userBubble: Color("BubbleOutgoing"),
            userBubbleText: Color("OnAccent"),
            assistantBubble: Color("BubbleIncoming"),
            assistantBubbleText: Color("TextPrimary"),
            divider: Color("Divider"),
            chartTrack: Color("ChartTrack"),
            chartColors: [
                Color("ChartSeries1"),
                Color("ChartSeries2"),
                Color("ChartSeries3"),
                Color("ChartSeries4"),
                Color("ChartSeries5")
            ],
            success: Color("Success"),
            warning: Color("Warning"),
            error: Color("Error"),
            overlay: Color.black.opacity(0.45)
        )
    }

    private static var hostFonts: TanyaAIFonts {
        TanyaAIFonts(
            title: .custom("HostSans-Bold", size: 28, relativeTo: .title),
            headline: .custom("HostSans-Semibold", size: 17, relativeTo: .headline),
            body: .custom("HostSans-Regular", size: 17, relativeTo: .body),
            subheadline: .custom("HostSans-Regular", size: 15, relativeTo: .subheadline),
            footnote: .custom("HostSans-Regular", size: 13, relativeTo: .footnote),
            caption: .custom("HostSans-Regular", size: 12, relativeTo: .caption),
            amount: .custom("HostSans-Bold", size: 22, relativeTo: .title2),
            button: .custom("HostSans-Semibold", size: 17, relativeTo: .headline)
        )
    }
}
