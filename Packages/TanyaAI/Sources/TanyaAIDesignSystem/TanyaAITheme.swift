import SwiftUI

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
        let accent = Color(red: 0.58, green: 0.04, blue: 0.12)
        return TanyaAIColors(
            background: Color(red: 0.98, green: 0.98, blue: 0.99),
            surface: .white,
            primaryText: Color(red: 0.08, green: 0.08, blue: 0.10),
            secondaryText: Color(red: 0.40, green: 0.40, blue: 0.44),
            accent: accent,
            userBubble: Color(red: 0.51, green: 0.04, blue: 0.12),
            userBubbleText: .white,
            assistantBubble: .white,
            assistantBubbleText: Color(red: 0.08, green: 0.08, blue: 0.10),
            divider: Color.black.opacity(0.12),
            chartTrack: Color.black.opacity(0.08),
            chartColors: [
                Color(red: 0.83, green: 0.04, blue: 0.16),
                Color(red: 0.91, green: 0.55, blue: 0.03),
                Color(red: 0.04, green: 0.47, blue: 0.77),
                Color(red: 0.05, green: 0.58, blue: 0.30),
                .gray
            ],
            success: .green,
            warning: .orange,
            error: .red,
            overlay: Color.black.opacity(0.45)
        )
    }

    private static var sandboxFonts: TanyaAIFonts {
        TanyaAIFonts(
            title: .title.bold(),
            headline: .headline.weight(.semibold),
            body: .body,
            subheadline: .subheadline,
            footnote: .footnote,
            caption: .caption,
            amount: .title2.bold(),
            button: .headline.weight(.semibold)
        )
    }
}
