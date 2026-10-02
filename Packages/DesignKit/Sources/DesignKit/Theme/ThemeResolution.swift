import SwiftUI
import UIKit

public extension Theme {
    /// Resolve from original typography descriptors; safe to call repeatedly.
    func resolved(artwork: ArtworkMetrics, traits: UITraitCollection) -> Theme {
        Theme(colors: colors, fonts: fonts.resolved(artwork: artwork, traits: traits))
    }
}

struct ResolvedTheme: ViewModifier {
    let theme: Theme
    @Environment(\.artwork) private var artwork
    @Environment(\.sizeCategory) private var sizeCategory

    func body(content: Content) -> some View {
        let resolved = theme.resolved(
            artwork: artwork,
            traits: UITraitCollection(preferredContentSizeCategory: sizeCategory.uiKitCategory)
        )
        return content
            .environment(\.theme, resolved)
            .foregroundColor(Color(resolved.colors.primaryText))
    }
}

private extension ContentSizeCategory {
    var uiKitCategory: UIContentSizeCategory {
        switch self {
        case .extraSmall: return .extraSmall
        case .small: return .small
        case .medium: return .medium
        case .large: return .large
        case .extraLarge: return .extraLarge
        case .extraExtraLarge: return .extraExtraLarge
        case .extraExtraExtraLarge: return .extraExtraExtraLarge
        case .accessibilityMedium: return .accessibilityMedium
        case .accessibilityLarge: return .accessibilityLarge
        case .accessibilityExtraLarge: return .accessibilityExtraLarge
        case .accessibilityExtraExtraLarge: return .accessibilityExtraExtraLarge
        case .accessibilityExtraExtraExtraLarge: return .accessibilityExtraExtraExtraLarge
        @unknown default: return .large
        }
    }
}
