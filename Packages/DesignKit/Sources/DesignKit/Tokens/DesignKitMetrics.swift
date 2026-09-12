import CoreGraphics

/// The measurements the components are built from.
///
/// Here rather than typed into each view, so a revamp changes a scale in one
/// place instead of hunting for the same number in fourteen files - and so
/// the numbers can be read as a system rather than guessed at individually.
///
/// Colours and type are not here: those arrive as a `TanyaAITheme`, which the
/// host supplies so a bank's own palette wins. These are the values that stay
/// the same whoever is using it.
public enum DesignKitMetrics {
    /// Space between and inside things. Steps roughly by a quarter each time,
    /// so two values next to each other read as deliberately different.
    public enum Spacing {
        /// 4 - between a label and the value directly under it.
        public static let tight: CGFloat = 4
        /// 6 - rows of a stack that belong to one another.
        public static let snug: CGFloat = 6
        /// 8 - between sibling rows: prompts, links.
        public static let compact: CGFloat = 8
        /// 12 - a bubble's vertical padding, and the gap inside a row.
        public static let regular: CGFloat = 12
        /// 14 - a caption's breathing room under artwork.
        public static let roomy: CGFloat = 14
        /// 16 - a bubble's horizontal padding, and the conversation's margin.
        public static let wide: CGFloat = 16
        /// 18 - the large cards' own padding, matching their corner.
        public static let card: CGFloat = 18
    }

    /// Corner rounding. One radius for everything that holds text, so the
    /// conversation reads as one set of shapes.
    public enum Radius {
        /// 12 - replies, prompts, hand-off links, image cards.
        public static let bubble: CGFloat = 12
        /// 16 - the small notice cards: status and information.
        public static let notice: CGFloat = 16
        /// 18 - the large cards: approval, receipt, chart, portfolio, list.
        ///
        /// Three radii rather than one is drift from before the design
        /// review, not a decision. Naming them is how it stops being
        /// invisible; collapsing them is a visual change and belongs to
        /// whoever owns the design, not to this file.
        public static let card: CGFloat = 18
    }

    /// How thick a drawn edge is.
    public enum Stroke {
        /// 1 - the outline around a reply, a prompt, a link.
        public static let hairline: CGFloat = 1
        /// 1.5 - the prompt's circle, which has to hold its own against text.
        public static let indicator: CGFloat = 1.5
    }

    /// Sizes that are not spacing.
    public enum Size {
        /// 44 - the smallest a tap target may be, from Apple's guidance.
        public static let minimumTapTarget: CGFloat = 44
        /// 20 - the prompt's circle.
        public static let indicator: CGFloat = 20
        /// 8 - one of the three waiting dots.
        public static let dot: CGFloat = 8
        /// 310 - how wide a bubble may grow.
        ///
        /// Short of the full width on purpose: a reply that reaches both
        /// edges stops looking like something someone said.
        public static let bubbleMaximumWidth: CGFloat = 310
    }

    /// Text laid out by hand rather than by the type scale.
    public enum Text {
        /// 4 - extra leading under a caption, which is set larger than body.
        public static let captionLineSpacing: CGFloat = 4
    }
}
