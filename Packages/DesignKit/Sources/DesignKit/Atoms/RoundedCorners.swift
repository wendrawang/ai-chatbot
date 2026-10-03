import SwiftUI

public struct RoundedCorners: Shape {
    public var radius: CGFloat = .infinity
    public var corners: UIRectCorner = .allCorners

    public init(radius: CGFloat, corners: UIRectCorner = .allCorners) {
        self.radius = radius
        self.corners = corners
    }

    public func path(in rectangle: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rectangle,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
