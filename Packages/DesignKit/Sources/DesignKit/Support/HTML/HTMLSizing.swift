import CoreGraphics

/// Keep malformed or extremely tall HTML from allocating a conversation-sized web view.
enum HTMLSizing {
    static let maximumHeight: CGFloat = 1_200
    static func height(_ proposed: CGFloat) -> CGFloat {
        guard proposed.isFinite else { return 120 }
        return min(maximumHeight, max(44, proposed))
    }
}
