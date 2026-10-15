import CoreGraphics
import Foundation

public extension DesignKitMetrics {
    enum Artwork {
        public static let referenceSize = CGSize(width: 375, height: 812)
        public static let maximumScale: CGFloat = 1.25
        public static let defaultDisplayScale: CGFloat = 2
    }

    enum Shadow {
        public static let composerOpacity: Double = 0.12
        public static let composerRadius: CGFloat = 4
        public static let composerOffset: CGFloat = 2
    }

    enum Layout {
        public static let measurementTolerance: CGFloat = 0.5
        public static let scrollFollowThreshold: CGFloat = 80
    }

    enum Opacity {
        public static let gradientStart: Double = 0.8
        public static let pressed: Double = 0.7
        public static let disabled: Double = 0.35
    }

    enum Motion {
        public static let navigationParallax: CGFloat = 0.3
        public static let navigationDuration: TimeInterval = 0.35
    }
}
