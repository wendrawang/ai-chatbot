//
//  CGFloat+Artwork.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import UIKit

public extension CGFloat {
    /// Uses the host's uncapped formula: round(value / (referenceWidth / screenWidth)).
    var scaledToArtwork: CGFloat {
        scaledToArtwork(ratio: CustomSizes.Artwork.currentRatio)
    }

    var strokeInArtwork: CGFloat {
        guard isFinite, self > InitialValues.zeroCGFloat else { return InitialValues.zeroCGFloat }
        return Swift.max(CustomSizes.Layout.minimumStrokePixels / UIScreen.main.scale, scaledToArtwork)
    }

    var tapTargetInArtwork: CGFloat {
        Swift.max(CustomSizes.ActionButton.minimumTapSize, scaledToArtwork)
    }
}

extension CGFloat {
    func scaledToArtwork(ratio: CGFloat) -> CGFloat {
        guard isFinite, ratio.isFinite, ratio > InitialValues.zeroCGFloat else {
            return InitialValues.zeroCGFloat
        }
        let scaled = self / ratio
        return scaled.isFinite ? scaled.rounded() : InitialValues.zeroCGFloat
    }
}
