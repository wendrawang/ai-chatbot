//
//  CustomScreenInsets.swift
//  DesignKit
//
//  Created by Wendra on 28/10/26.
//

import CoreGraphics

/// Jarak dari tepi atas layar fisik (bukan safe area), mengikuti navigation bar host agar header
/// konsisten saat berpindah halaman. Nilai ini TIDAK pernah di-scale, sama seperti di host.
public enum CustomScreenInsets {
    /// Padding atas header pada perangkat dengan notch / Dynamic Island.
    public static let headerTopWithNotch: CGFloat = 50
    /// Padding atas header pada perangkat dengan status bar klasik.
    public static let headerTop: CGFloat = 28
    /// Tinggi status bar klasik; safe area atas yang lebih besar berarti perangkat punya notch.
    public static let classicStatusBar: CGFloat = 20
}
