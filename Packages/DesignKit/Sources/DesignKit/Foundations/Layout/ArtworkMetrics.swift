import UIKit

/// Pure size calculation. Components use the screen-based CGFloat properties below.
public struct ArtworkMetrics: Equatable {
    public static let referenceSize = DesignKitMetrics.Artwork.referenceSize
    public let scale: CGFloat
    public let displayScale: CGFloat

    /// Read current screen dimensions; no environment, observer or cached window is needed.
    public static var screen: ArtworkMetrics {
        ArtworkMetrics(containerSize: UIScreen.main.bounds.size, displayScale: UIScreen.main.scale)
    }

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
        let scaled = value * scale
        guard scaled.isFinite else { return 0 }
        return scaled.rounded()
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
    /// Figma value scaled from the hardcoded reference width to the main screen, rounded to points.
    var sizeInArtwork: CGFloat { ArtworkMetrics.screen.size(self) }

    /// Positive strokes retain at least one physical pixel.
    var strokeInArtwork: CGFloat { ArtworkMetrics.screen.stroke(self) }

    /// Touch areas retain at least 44 points after scaling.
    var tapTargetInArtwork: CGFloat { ArtworkMetrics.screen.tapTarget(self) }
}
