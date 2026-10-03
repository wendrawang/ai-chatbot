import CoreGraphics

/// Converts Figma points using the active container, never a cached screen size.
public struct ArtworkMetrics: Equatable {
    public static let referenceSize = DesignKitMetrics.Artwork.referenceSize
    public let scale: CGFloat
    public let displayScale: CGFloat

    public init(
        containerSize: CGSize = Self.referenceSize,
        referenceSize: CGSize = Self.referenceSize,
        displayScale: CGFloat = DesignKitMetrics.Artwork.defaultDisplayScale,
        maximumScale: CGFloat = DesignKitMetrics.Artwork.maximumScale
    ) {
        let width = referenceSize.width.isFinite && referenceSize.width > 0
            ? referenceSize.width : Self.referenceSize.width
        let ratio = containerSize.width / width
        let limit = maximumScale.isFinite && maximumScale > 0 ? maximumScale : DesignKitMetrics.Artwork.maximumScale
        scale = ratio.isFinite && ratio > 0 ? min(ratio, limit) : 1
        self.displayScale = displayScale.isFinite && displayScale > 0
            ? displayScale : DesignKitMetrics.Artwork.defaultDisplayScale
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
    public func tapTarget(_ value: CGFloat = DesignKitMetrics.Size.minimumTapTarget) -> CGFloat {
        max(DesignKitMetrics.Size.minimumTapTarget, size(value))
    }
}

public extension CGFloat {
    /// Explicit context supports multiple windows, rotation and split screen.
    func sizeInArtwork(_ artwork: ArtworkMetrics) -> CGFloat {
        artwork.size(self)
    }
}
