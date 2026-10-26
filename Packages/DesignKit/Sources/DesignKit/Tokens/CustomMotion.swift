//
//  CustomMotion.swift
//  DesignKit
//
//  Created by Wendra on 26/10/26.
//

import Foundation

/// Waktu dan jumlah langkah animasi. Bukan ukuran, jadi tidak pernah di-scale.
public enum CustomMotion {
    public enum LoadingDots {
        public static let count = 3
        /// Detik untuk satu putaran lompatan.
        public static let period: Double = 0.9
        /// Jeda antar titik, dalam detik.
        public static let stagger: Double = 0.15
        /// Satu putaran penuh gelombang sinus.
        public static let fullTurn = 2 * Double.pi
    }
}
