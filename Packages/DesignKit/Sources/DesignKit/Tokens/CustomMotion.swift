//
//  CustomMotion.swift
//  DesignKit
//
//  Created by Wendra on 18/10/26.
//

import CoreGraphics
import Foundation

/// Durasi dan ambang gesture. Nilai waktu/rasio, tidak pernah di-scale.
public enum CustomMotion {
    public enum Navigation {
        public static let duration: TimeInterval = 0.35
        /// Jarak geser halaman di belakang, relatif terhadap halaman yang masuk (UINavigationController ≈ 0.3).
        public static let parallax: CGFloat = 0.3
    }

    public enum SwipeBack {
        /// Selesai jika melewati setengah lebar layar...
        public static let progress: CGFloat = 0.5
        /// ...atau dilempar lebih cepat dari 300 pt/detik.
        public static let velocity: CGFloat = 300
    }
}
