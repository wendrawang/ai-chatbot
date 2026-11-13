//
//  BottomSheetStateTests.swift
//  DesignKitTests
//
//  Created by Wendra on 13/11/26.
//

import SwiftUI
import Testing
import UIKit

@testable import DesignKit

/// Isi yang tumbuh melewati batas sheet mulai di-scroll di scroll view yang sama tanpa dibuat ulang, jadi state di
/// dalamnya (mis. centang sementara `OptionList`) tetap ada. Berurutan karena memakai window.
@MainActor
@Suite(.serialized)
struct BottomSheetStateTests {
    private let rowHeight: CGFloat = 44
    private let maxHeight: CGFloat = 300

    @Test
    func theContentKeepsItsStateWhenItStartsScrolling() async throws {
        var appearCount = 0
        let host = UIHostingController(rootView: sheet(rows: 2) { appearCount += 1 })
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        window.rootViewController = host
        window.makeKeyAndVisible()
        defer { window.isHidden = true }
        await waitUntil { appearCount == 1 && window.scrollViews.count == 1 }
        let scrollView = try #require(window.scrollViews.first)
        #expect(!scrollView.isScrollEnabled, "isi yang muat tidak di-scroll")

        host.rootView = sheet(rows: 30) { appearCount += 1 }
        await waitUntil { scrollView.isScrollEnabled && scrollView.contentSize.height > scrollView.bounds.height }
        try await Task.sleep(nanoseconds: 200_000_000)
        #expect(appearCount == 1, "isi dibuat ulang saat mulai di-scroll")
        #expect(window.scrollViews == [scrollView])
    }
}

// MARK: - Helpers

private extension BottomSheetStateTests {
    func sheet(rows: Int, onAppear: @escaping () -> Void) -> some View {
        BottomSheet(
            closeLabel: "Tutup",
            bottomInset: .zero,
            maxHeight: maxHeight,
            onClose: {},
            content: {
                VStack(spacing: .zero) {
                    Color.clear.frame(height: rowHeight).onAppear(perform: onAppear)
                    ForEach(0..<rows, id: \.self) { _ in Color.clear.frame(height: rowHeight) }
                }
            }
        )
    }
}
