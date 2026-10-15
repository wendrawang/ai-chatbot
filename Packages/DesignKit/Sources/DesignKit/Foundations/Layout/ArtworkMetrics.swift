import UIKit

/// A sizing snapshot for typography, geometry tests and table layout invalidation.
/// Components use the screen-based CGFloat extension in Extensions/CGFloat+Artwork.swift.
public struct ArtworkMetrics: Equatable {
    public static let referenceSize = CGSize(
        width: DesignKitMetrics.Artwork.width, height: DesignKitMetrics.Artwork.height
    )
    public let scale: CGFloat
    public let displayScale: CGFloat
    private let ratio: CGFloat

    /// Read current screen dimensions; no environment, observer or cached window is needed.
    public static var screen: ArtworkMetrics {
        ArtworkMetrics(containerSize: UIScreen.main.bounds.size, displayScale: UIScreen.main.scale)
    }

    public init(
        containerSize: CGSize = Self.referenceSize,
        referenceSize: CGSize = Self.referenceSize,
        displayScale: CGFloat = DesignKitMetrics.Artwork.defaultDisplayScale
    ) {
        let width =
            referenceSize.width.isFinite && referenceSize.width > 0
            ? referenceSize.width : Self.referenceSize.width
        let ratio = width / containerSize.width
        self.ratio = ratio.isFinite && ratio > 0 ? ratio : 1
        scale = 1 / self.ratio
        self.displayScale =
            displayScale.isFinite && displayScale > 0
            ? displayScale : DesignKitMetrics.Artwork.defaultDisplayScale
    }

    /// Uniform width scaling preserves proportions; height never stretches independently.
    public func size(_ value: CGFloat) -> CGFloat {
        value.scaledToArtwork(ratio: ratio)
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
