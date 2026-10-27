//
//  CustomMotion.swift
//  DesignKit
//
//  Created by Wendra on 27/10/26.
//

import Foundation

/// Nilai waktu animasi yang belum ada di Figma. Detik, tidak pernah di-scale.
public enum CustomMotion {
    /// Titik yang naik-turun bergantian sebagai tanda menunggu.
    /// TODO: Cocokkan dengan prototype Figma; sementara estimasi.
    public enum LoadingDots {
        /// Jumlah titik; bukan ukuran, jadi ikut tidak di-scale.
        public static let dotCount = 3
        public static let bounceDuration: TimeInterval = 0.35
        public static let stagger: TimeInterval = 0.12
    }
}
