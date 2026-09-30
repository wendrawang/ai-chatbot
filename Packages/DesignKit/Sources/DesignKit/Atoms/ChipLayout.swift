import CoreGraphics

/// Packs chips into rows that fit a given width.
///
/// A plain function rather than SwiftUI layout tricks, for two reasons. On
/// iOS 15 there is no `Layout` protocol, so the alternative is mutating
/// captured state inside `alignmentGuide` - which works but cannot be tested
/// and misbehaves when it is measured twice. And packing is the part most
/// likely to be wrong, so it is the part worth being able to assert on.
enum ChipLayout {
    /// Row indices into `widths`, in order.
    ///
    /// A chip wider than the row gets a row to itself rather than being
    /// dropped: the text still wraps inside it, and losing a choice would be
    /// worse than a chip that reaches both edges.
    static func rows(
        widths: [CGFloat],
        maxWidth: CGFloat,
        spacing: CGFloat
    ) -> [[Int]] {
        var rows: [[Int]] = []
        var current: [Int] = []
        var used: CGFloat = 0

        for (index, width) in widths.enumerated() {
            let needed = current.isEmpty ? width : used + spacing + width
            if current.isEmpty == false, needed > maxWidth {
                rows.append(current)
                current = [index]
                used = width
                continue
            }
            current.append(index)
            used = needed
        }
        if current.isEmpty == false {
            rows.append(current)
        }
        return rows
    }
}
