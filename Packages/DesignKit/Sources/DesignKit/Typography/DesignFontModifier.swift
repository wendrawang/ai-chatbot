import SwiftUI
import UIKit

public enum DesignFontRole: Int {
    case title, headline, body, subheadline, footnote, caption, amount, button
}

public extension Fonts {
    func font(for role: DesignFontRole) -> UIFont {
        switch role {
        case .title: return title
        case .headline: return headline
        case .body: return body
        case .subheadline: return subheadline
        case .footnote: return footnote
        case .caption: return caption
        case .amount: return amount
        case .button: return button
        }
    }

    /// Extra leading only; glyph ascenders/descenders are never clipped to a fixed height.
    func lineSpacing(for role: DesignFontRole) -> CGFloat {
        guard let recipe = recipes?[role.rawValue],
              let lineHeight = recipe.lineHeight, recipe.size > 0 else { return 0 }
        let resolved = font(for: role)
        return max(0, lineHeight * resolved.pointSize / recipe.size - resolved.lineHeight)
    }
}

private struct DesignFontModifier: ViewModifier {
    let role: DesignFontRole
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .font(Font(theme.fonts.font(for: role)))
            .lineSpacing(theme.fonts.lineSpacing(for: role))
    }
}

public extension View {
    /// Uses the resolved theme font and its optional Figma leading.
    func designFont(_ role: DesignFontRole) -> some View {
        modifier(DesignFontModifier(role: role))
    }
}
