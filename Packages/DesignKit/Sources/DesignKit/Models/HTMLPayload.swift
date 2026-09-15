import CoreGraphics
import Foundation

/// A fragment of static HTML, for results that are easier to lay out as a
/// table than to describe as a card.
///
/// Static is the whole contract. JavaScript is disabled when this is drawn, so
/// anything that needs to run will not - use `content.chart` for charts, which
/// follows the theme, scales with Dynamic Type and can be read aloud.
public struct HTMLPayload: Equatable {
    public let identifier: String
    public let html: String

    /// How tall the fragment is, in points.
    ///
    /// Send it. The row is given this height before the HTML is laid out, and
    /// a measured correction afterwards moves the conversation under whoever
    /// is reading it. A close guess that is never corrected beats an accurate
    /// one that arrives late.
    public let declaredHeight: CGFloat?

    /// What the fragment says, for VoiceOver.
    ///
    /// Without it the bubble is announced as a web area, which tells a
    /// customer using VoiceOver nothing at all.
    public let accessibilityText: String?

    /// Used when the payload does not say. Tall enough for a few rows of a
    /// small table, which is what this is mostly for.
    public static let defaultHeight: CGFloat = 180

    public init(
        identifier: String,
        html: String,
        declaredHeight: CGFloat? = nil,
        accessibilityText: String? = nil
    ) {
        self.identifier = identifier
        self.html = html
        // Zero or a negative height is not a height; treated as unsaid.
        self.declaredHeight = (declaredHeight ?? 0) > 0 ? declaredHeight : nil
        self.accessibilityText = accessibilityText
    }

    public var initialHeight: CGFloat {
        declaredHeight ?? Self.defaultHeight
    }
}
