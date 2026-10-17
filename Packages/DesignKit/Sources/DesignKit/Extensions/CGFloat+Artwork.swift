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
}

extension CGFloat {
    func scaledToArtwork(ratio: CGFloat) -> CGFloat {
        guard isFinite, ratio.isFinite, ratio > .zero else {
            return .zero
        }
        let scaled = self / ratio
        return scaled.isFinite ? scaled.rounded() : .zero
    }
}
