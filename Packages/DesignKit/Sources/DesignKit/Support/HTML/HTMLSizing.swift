import CoreGraphics

/// Keep malformed or extremely tall HTML from allocating a conversation-sized web view.
enum HTMLSizing {
    static let maximumHeight: CGFloat = DesignKitMetrics.Web.maximumHeight
    static func height(_ proposed: CGFloat) -> CGFloat {
        guard proposed.isFinite else { return DesignKitMetrics.Web.fallbackHeight }
        return min(maximumHeight, max(DesignKitMetrics.Size.minimumTapTarget, proposed))
    }
}
