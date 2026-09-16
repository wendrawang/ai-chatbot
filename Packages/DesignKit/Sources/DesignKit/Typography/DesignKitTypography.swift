import SwiftUI
import UIKit

/// Sizes are supplied by generated tokens; this type never duplicates their values.
public struct DesignKitTypography {
    public let postScriptName: String
    public let size: CGFloat
    public let style: UIFont.TextStyle
    public let fallbackWeight: UIFont.Weight

    public init(
        postScriptName: String,
        size: CGFloat,
        style: UIFont.TextStyle,
        fallbackWeight: UIFont.Weight = .regular
    ) {
        self.postScriptName = postScriptName
        self.size = size
        self.style = style
        self.fallbackWeight = fallbackWeight
    }

    public func font(compatibleWith traits: UITraitCollection? = nil) -> UIFont {
        let baseFont = UIFont(name: postScriptName, size: size)
            ?? UIFont.systemFont(ofSize: size, weight: fallbackWeight)
        return UIFontMetrics(forTextStyle: style).scaledFont(for: baseFont, compatibleWith: traits)
    }

    public func swiftUIFont(relativeTo style: Font.TextStyle = .body) -> Font {
        .custom(postScriptName, size: size, relativeTo: style)
    }
}
