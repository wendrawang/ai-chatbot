//
//  OptionListFocusTests.swift
//  DesignKitTests
//
//  Created by Wendra on 13/11/26.
//

import SwiftUI
import Testing
import UIKit

@testable import DesignKit

/// Daftar panjang di sheet dibuka di pilihan sebelumnya, bukan dari atas: makin jauh pilihannya, makin jauh daftar
/// digulir. Posisi tengahnya dijaga `BottomSheetFocusTests`. Berurutan karena memakai window.
@MainActor
@Suite(.serialized)
struct OptionListFocusTests {
    private let items = (0..<40).map { OptionItem(id: String($0), title: "Rekening \($0)") }

    @Test
    func theListOpensAtThePreviousChoice() async throws {
        try FontFace.registerFonts()
        let nearTop = try await openedOffset(selectedIDs: ["0"])
        let middle = try await openedOffset(selectedIDs: ["20"])
        let farDown = try await openedOffset(selectedIDs: ["30"])
        #expect(nearTop <= 0.5, "pilihan di atas tidak menggulir daftar")
        #expect(middle > nearTop)
        #expect(farDown > middle)
    }

    @Test
    func choicesOnlyComeFromTheCallerSelection() async throws {
        try FontFace.registerFonts()
        let unselected = try await openedOffset(selectedIDs: [])
        let unknown = try await openedOffset(selectedIDs: ["missing"])
        #expect(unselected <= 0.5)
        #expect(unknown <= 0.5)
    }
}

// MARK: - Helpers

private extension OptionListFocusTests {
    /// Posisi gulir setelah sheet terukur dan mulai di-scroll, dihitung dari atas isi.
    func openedOffset(selectedIDs: [String]) async throws -> CGFloat {
        let sheet = BottomSheet(
            closeLabel: "Tutup",
            bottomInset: .zero,
            maxHeight: 400,
            onClose: {},
            content: { OptionList(title: "Rekening", items: items, selectedIDs: selectedIDs, onSelect: { _ in }) }
        )
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        window.rootViewController = UIHostingController(rootView: sheet)
        window.makeKeyAndVisible()
        defer { window.isHidden = true }
        await waitUntil { window.scrollViews.first?.isScrollEnabled == true }
        try await Task.sleep(nanoseconds: 300_000_000)
        let scrollView = try #require(window.scrollViews.first)
        return scrollView.contentOffset.y + scrollView.adjustedContentInset.top
    }
}
