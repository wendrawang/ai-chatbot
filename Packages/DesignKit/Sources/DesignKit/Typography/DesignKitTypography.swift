import SwiftUI
import UIKit

/// Sizes are supplied by generated tokens; this type never duplicates their values.
public struct DesignKitTypography: Equatable {
    public let postScriptName: String
    public let size: CGFloat
    public let style: UIFont.TextStyle
    public let fallbackWeight: UIFont.Weight
    public let lineHeight: CGFloat?

    public init(
        postScriptName: String,
        size: CGFloat,
        style: UIFont.TextStyle,
        fallbackWeight: UIFont.Weight = .regular,
        lineHeight: CGFloat? = nil
    ) {
        self.postScriptName = postScriptName
        self.size = size
        self.style = style
        self.fallbackWeight = fallbackWeight
        self.lineHeight = lineHeight
    }

    public func font(
        compatibleWith traits: UITraitCollection? = nil,
        artwork: ArtworkMetrics = ArtworkMetrics()
    ) -> UIFont {
        let size = artwork.size(self.size)
        let baseFont = UIFont(name: postScriptName, size: size)
            ?? UIFont.systemFont(ofSize: size, weight: fallbackWeight)
        return UIFontMetrics(forTextStyle: style).scaledFont(for: baseFont, compatibleWith: traits)
    }

    public func swiftUIFont(
        relativeTo style: Font.TextStyle? = nil,
        artwork: ArtworkMetrics = ArtworkMetrics()
    ) -> Font {
        .custom(postScriptName, size: artwork.size(size), relativeTo: style ?? swiftUIStyle)
    }

    private var swiftUIStyle: Font.TextStyle {
        switch style {
        case .largeTitle: return .largeTitle
        case .title1: return .title
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption1: return .caption
        case .caption2: return .caption2
        default: return .body
        }
    }
}
