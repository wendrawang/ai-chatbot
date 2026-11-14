//
//  BottomSheetFocusTests.swift
//  DesignKitTests
//
//  Created by Wendra on 13/11/26.
//

import SwiftUI
import Testing
import UIKit

@testable import DesignKit

/// Isi panjang dengan `BottomSheetFocus` dibuka dengan penanda itu di tengah sheet; tanpa penanda, isi mulai dari
/// atas. Berurutan karena memakai window.
@MainActor
@Suite(.serialized)
struct BottomSheetFocusTests {
    private let rowHeight: CGFloat = 44
    private let focusedRow = 25

    @Test
    func theFocusedRowOpensInTheMiddleOfTheSheet() async throws {
        let (window, scrollView) = try await openSheet(focusedRow: focusedRow)
        defer { window.isHidden = true }
        let rowCenter = CGFloat(focusedRow) * rowHeight + rowHeight / 2
        let expected = rowCenter - scrollView.bounds.height / 2 - scrollView.adjustedContentInset.top
        await waitUntil { abs(scrollView.contentOffset.y - expected) <= 1 }
    }

    @Test
    func withoutAFocusTheContentStartsAtTheTop() async throws {
        let (window, scrollView) = try await openSheet(focusedRow: nil)
        defer { window.isHidden = true }
        try await Task.sleep(nanoseconds: 300_000_000)
        #expect(scrollView.contentOffset.y <= -scrollView.adjustedContentInset.top + 0.5)
    }
}

// MARK: - Helpers

private extension BottomSheetFocusTests {
    func openSheet(focusedRow: Int?) async throws -> (UIWindow, UIScrollView) {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        window.rootViewController = UIHostingController(rootView: sheet(focusedRow: focusedRow))
        window.makeKeyAndVisible()
        await waitUntil { window.scrollViews.first?.isScrollEnabled == true }
        return (window, try #require(window.scrollViews.first))
    }

    func sheet(focusedRow: Int?) -> some View {
        BottomSheet(
            closeLabel: "Tutup",
            bottomInset: .zero,
            maxHeight: 300,
            onClose: {},
            content: {
                ForEach(0..<40, id: \.self) { row in
                    Color.clear.frame(height: rowHeight)
                        .id(row == focusedRow ? AnyHashable(BottomSheetFocus.id) : AnyHashable(row))
                }
            }
        )
    }
}
