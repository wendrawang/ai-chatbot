//
//  ScreenFooterPlacementKey.swift
//  DesignKit
//
//  Created by Wendra on 26/11/26.
//

import SwiftUI

/// Dikirim input di dalam footer `ScreenScaffold`. Footer yang tidak mengirim apa pun tetap mengikuti keyboard
/// (perilaku bawaan); `.bottom` hanya berlaku bila dikirim eksplisit.
struct ScreenFooterPlacementKey: PreferenceKey {
    static var defaultValue: ScreenFooterPlacement { .aboveKeyboard }

    static func reduce(value: inout ScreenFooterPlacement, nextValue: () -> ScreenFooterPlacement) {
        guard value == .aboveKeyboard else { return }
        value = nextValue()
    }
}
