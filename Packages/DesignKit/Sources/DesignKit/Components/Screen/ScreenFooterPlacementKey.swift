//
//  ScreenFooterPlacementKey.swift
//  DesignKit
//
//  Created by Wendra on 26/11/26.
//

import SwiftUI

/// Dikirim input di dalam footer `ScreenScaffold`; satu input yang sedang diketik cukup untuk menaikkan footer.
struct ScreenFooterPlacementKey: PreferenceKey {
    static var defaultValue: ScreenFooterPlacement { .bottom }

    static func reduce(value: inout ScreenFooterPlacement, nextValue: () -> ScreenFooterPlacement) {
        guard value == .bottom else { return }
        value = nextValue()
    }
}
