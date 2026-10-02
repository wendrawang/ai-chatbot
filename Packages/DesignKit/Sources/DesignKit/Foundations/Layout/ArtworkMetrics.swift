import CoreGraphics

/// Converts Figma points using the active container, never a cached screen size.
public struct ArtworkMetrics: Equatable {
    public static let referenceSize = CGSize(width: 375, height: 812)
    public let scale: CGFloat
    public let displayScale: CGFloat

    public init(
        containerSize: CGSize = Self.referenceSize,
        referenceSize: CGSize = Self.referenceSize,
        displayScale: CGFloat = 2,
        maximumScale: CGFloat = 1.25
    ) {
        let width = referenceSize.width.isFinite && referenceSize.width > 0 ? referenceSize.width : 375
        let ratio = containerSize.width / width
        let limit = maximumScale.isFinite && maximumScale > 0 ? maximumScale : 1.25
        scale = ratio.isFinite && ratio > 0 ? min(ratio, limit) : 1
        self.displayScale = displayScale.isFinite && displayScale > 0 ? displayScale : 2
    }

    /// Uniform width scaling preserves proportions; height never stretches independently.
    public func size(_ value: CGFloat) -> CGFloat {
        guard value.isFinite else { return 0 }
        let pixels = value * scale * displayScale
        guard pixels.isFinite else { return 0 }
        return pixels.rounded() / displayScale
    }

    public func stroke(_ value: CGFloat) -> CGFloat {
        guard value.isFinite, value > 0 else { return 0 }
        return max(1 / displayScale, size(value))
    }

    /// Accessibility targets must not shrink below 44 points on narrow containers.
    public func tapTarget(_ value: CGFloat = 44) -> CGFloat {
        max(44, size(value))
    }
}

public extension CGFloat {
    /// Explicit context supports multiple windows, rotation and split screen.
    func sizeInArtwork(_ artwork: ArtworkMetrics) -> CGFloat {
        artwork.size(self)
    }
}
