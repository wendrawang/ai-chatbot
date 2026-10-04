import CoreGraphics
import Foundation

public extension DesignKitMetrics {
    enum Artwork {
        public static let referenceSize = CGSize(width: 374, height: 812)
        public static let maximumScale: CGFloat = 1.25
        public static let defaultDisplayScale: CGFloat = 2
    }

    enum Layout {
        public static let measurementTolerance: CGFloat = 0.5
        public static let scrollFollowThreshold: CGFloat = 80
    }

    enum Web {
        public static let maximumHeight: CGFloat = 1_200
        public static let fallbackHeight: CGFloat = 120
        public static let initialHeight: CGFloat = 180
        public static let headerWeight = 600
    }

    enum Opacity {
        public static let pressed: Double = 0.7
        public static let disabled: Double = 0.35
        public static let disabledSend: Double = 0.4
        public static let selected: Double = 0.1
        public static let restingDot: Double = 0.3
    }

    enum Motion {
        public static let navigationParallax: CGFloat = 0.3
        public static let navigationDuration: TimeInterval = 0.35
        public static let dotCount = 3
        public static let dotDuration: TimeInterval = 0.6
        public static let dotDelay: TimeInterval = 0.2
    }
}
