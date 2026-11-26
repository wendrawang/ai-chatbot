//
//  ScreenFooterTopKey.swift
//  DesignKit
//
//  Created by Wendra on 26/11/26.
//

import SwiftUI

/// Tepi atas footer `ScreenScaffold` di koordinat layar, untuk menghitung jarak bawah konten.
struct ScreenFooterTopKey: PreferenceKey {
    static var defaultValue: CGFloat { .infinity }

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = min(value, nextValue())
    }
}
