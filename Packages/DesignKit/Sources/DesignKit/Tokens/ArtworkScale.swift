//
//  ArtworkScale.swift
//  DesignKit
//
//  Created by Wendra on 18/10/26.
//

import UIKit

/// Referensi artwork Figma untuk `.scaledToArtwork`: round(nilai / (375 / lebar layar)), tanpa cap.
public enum ArtworkScale {
    public static let referenceWidth: CGFloat = 375
    /// Metadata saja; skala hanya mengikuti lebar.
    public static let referenceHeight: CGFloat = 812
    public static var currentRatio: CGFloat { referenceWidth / UIScreen.main.bounds.width }
}
