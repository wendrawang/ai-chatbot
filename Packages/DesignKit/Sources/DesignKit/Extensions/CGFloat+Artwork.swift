import UIKit

public extension CGFloat {
    /// Scales a Figma measurement by the current artwork-to-screen ratio, rounded to points.
    var scaledToArtwork: CGFloat {
        scaledToArtwork(ratio: DesignKitMetrics.Artwork.currentRatio)
    }

    /// Positive strokes retain at least one physical pixel.
    var strokeInArtwork: CGFloat { ArtworkMetrics.screen.stroke(self) }

    /// Touch areas retain at least 44 points after scaling.
    var tapTargetInArtwork: CGFloat { ArtworkMetrics.screen.tapTarget(self) }
}

extension CGFloat {
    /// Shared arithmetic keeps screen sizing and explicit typography snapshots identical.
    func scaledToArtwork(ratio: CGFloat) -> CGFloat {
        guard isFinite else { return 0 }
        let ratio = ratio.isFinite && ratio > 0 ? ratio : 1
        let scaled = self / ratio
        return scaled.isFinite ? scaled.rounded() : 0
    }
}
