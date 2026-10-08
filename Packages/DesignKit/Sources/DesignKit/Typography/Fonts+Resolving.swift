import UIKit

public extension Fonts {
    /// Descriptor initializer: preserves unscaled values across theme and trait updates.
    init(
        title: DesignKitTypography,
        headline: DesignKitTypography,
        body: DesignKitTypography,
        subheadline: DesignKitTypography,
        footnote: DesignKitTypography,
        caption: DesignKitTypography,
        amount: DesignKitTypography,
        button: DesignKitTypography
    ) {
        self.init(recipes: [title, headline, body, subheadline, footnote, caption, amount, button])
    }

    /// Legacy UIFont-only palettes are left unchanged because their base scale is unknown.
    func resolved(artwork: ArtworkMetrics = .screen, traits: UITraitCollection) -> Fonts {
        guard let recipes else { return self }
        return Fonts(recipes: recipes, artwork: artwork, traits: traits)
    }
}

extension Fonts {
    init(
        recipes: [DesignKitTypography],
        artwork: ArtworkMetrics = .screen,
        traits: UITraitCollection? = nil
    ) {
        let values = recipes.map { $0.font(compatibleWith: traits, artwork: artwork) }
        self.init(
            title: values[0], headline: values[1], body: values[2], subheadline: values[3],
            footnote: values[4], caption: values[5], amount: values[6], button: values[7]
        )
        self.recipes = recipes
    }
}
