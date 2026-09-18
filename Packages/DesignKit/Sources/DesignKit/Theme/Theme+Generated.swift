import UIKit

public extension Theme {
    /// The only mapping layer between engine-owned tokens and component semantics.
    init(tokens: any FigmaColorProtocol, fonts: Fonts) {
        self.init(
            colors: Colors(
                background: UIColor(tokens.colorsSurfacePrimary),
                surface: UIColor(tokens.colorsSurfaceSelected),
                primaryText: UIColor(tokens.colorsTextPrimaryDark),
                secondaryText: UIColor(tokens.colorsTextSecondary),
                accent: UIColor(tokens.colorsButtonActive),
                userBubble: UIColor(tokens.colorsButtonActive),
                userBubbleText: UIColor(tokens.colorsTextSelectedOnColored),
                assistantBubble: UIColor(tokens.colorsSurfacePrimary),
                assistantBubbleText: UIColor(tokens.colorsTextPrimaryDark),
                divider: UIColor(tokens.colorsOutlineNetral),
                chartTrack: UIColor(tokens.colorsSurfaceDisable),
                chartColors: [
                    UIColor(tokens.colorsIconColored),
                    UIColor(tokens.colorsIconOngoing),
                    UIColor(tokens.colorsIconHyperlink),
                    UIColor(tokens.colorsIconSuccess)
                ],
                success: UIColor(tokens.colorsTextPositive),
                warning: UIColor(tokens.colorsIconOngoing),
                error: UIColor(tokens.colorsTextNegative),
                overlay: UIColor(tokens.colorsSurfaceOverlay24).withAlphaComponent(0.24)
            ),
            fonts: fonts
        )
    }
}

public extension ThemeManager {
    /// Premier and Private currently use explicitly marked development palettes.
    convenience init(fonts: Fonts, selected: ThemeVariant = .default) {
        self.init(
            defaultTheme: Theme(tokens: DefaultColorConstants(), fonts: fonts),
            premierTheme: Theme(tokens: PremierColorConstants(), fonts: fonts),
            privateTheme: Theme(tokens: PrivateColorConstants(), fonts: fonts),
            selected: selected
        )
    }
}
