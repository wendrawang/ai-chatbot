//
//  CustomSizes.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import UIKit

/// Measurements absent from generated tokens. Use FigmaSize's named spacing directly.
public enum CustomSizes {
    public enum Artwork {
        public static let width: CGFloat = 375
        public static let height: CGFloat = 812
        public static var currentRatio: CGFloat { width / UIScreen.main.bounds.width }
    }

    public enum InputText {
        public static let minimumLines = 1
        public static let maximumLines = 4
    }

    public enum Header {
        public static let height: CGFloat = 56
        public static let titleLines = 1
    }

    public enum ActionButton {
        public static let visualSize: CGFloat = 24
        public static let iconInset: CGFloat = 6
    }

    public enum Radius {
        public static let composer: CGFloat = 8
    }

    public enum Shadow {
        public static let radius: CGFloat = 10
        public static let offsetY: CGFloat = 2
    }

    public enum Layout {
        public static let measurementTolerance: CGFloat = 0.5
    }

    public enum Motion {
        public static let navigationParallax: CGFloat = 0.3
        public static let navigationDuration: TimeInterval = 0.35
    }
}
