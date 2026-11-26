//
//  ScreenScaffoldTests.swift
//  DesignKit
//
//  Created by Wendra on 26/11/26.
//

import SwiftUI
import Testing

@testable import DesignKit

/// Konten berakhir di atas footer, kecuali keyboard dari konten menutupi footer yang meminta `.bottom`: saat itu
/// konten berakhir tepat di atas keyboard. Angka mengikuti layar 812 pt dengan home indicator 34 pt, footer 78 pt,
/// dan keyboard 336 pt.
@MainActor
struct ScreenScaffoldTests {
    private typealias Scaffold = ScreenScaffold<EmptyView, EmptyView, EmptyView, EmptyView>

    @Test
    func contentEndsAboveTheFooterWithoutKeyboard() {
        #expect(Scaffold.footerOverlap(bottom: 778, footerTop: 700) == 78)
    }

    @Test
    func contentEndsAboveTheFooterWhileTheFooterInputIsTyped() {
        #expect(Scaffold.footerOverlap(bottom: 476, footerTop: 398) == 78)
    }

    @Test
    func contentEndsAtTheKeyboardWhenTheKeyboardCoversTheFooter() {
        #expect(Scaffold.footerOverlap(bottom: 476, footerTop: 700) == .zero)
    }

    @Test
    func contentKeepsItsHeightBeforeTheFooterIsMeasured() {
        #expect(Scaffold.footerOverlap(bottom: 778, footerTop: .infinity) == .zero)
    }

    /// Footer host tanpa preference (mis. `TextField` biasa) tetap naik di atas keyboard seperti sebelumnya.
    @Test
    func footersWithoutAPlacementFollowTheKeyboard() {
        #expect(ScreenFooterPlacementKey.defaultValue == .aboveKeyboard)
        #expect(reducedPlacement([.aboveKeyboard, .aboveKeyboard]) == .aboveKeyboard)
    }

    /// `.bottom` hanya berlaku bila dikirim eksplisit, mis. composer yang tidak sedang diketik.
    @Test
    func anExplicitBottomPlacementKeepsTheFooterUnderTheKeyboard() {
        #expect(reducedPlacement([.aboveKeyboard, .bottom]) == .bottom)
        #expect(reducedPlacement([.bottom, .aboveKeyboard]) == .bottom)
    }
}

// MARK: - Helpers

private extension ScreenScaffoldTests {
    func reducedPlacement(_ placements: [ScreenFooterPlacement]) -> ScreenFooterPlacement {
        var value = ScreenFooterPlacementKey.defaultValue
        for placement in placements {
            ScreenFooterPlacementKey.reduce(value: &value) { placement }
        }
        return value
    }
}
