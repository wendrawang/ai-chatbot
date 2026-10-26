//
//  ScreenHeaderTests.swift
//  DesignKit
//
//  Created by Wendra on 16/10/26.
//

import SwiftUI
import Testing

@testable import DesignKit

@MainActor
struct ScreenHeaderTests {
    @Test
    func longTitlesStayWithinCompactWidthsWithAndWithoutTrailingAction() throws {
        try FontFace.registerFonts()
        for width: CGFloat in [320, 375, 430] {
            for isScrolled in [false, true] {
                let title = String(repeating: "Judul panjang 中文 English ", count: 12)
                let bare = ScreenHeader(title: title, backLabel: "Back", isScrolled: isScrolled, onBack: {})
                let actions = ScreenHeader(
                    title: title, backLabel: "Back", isScrolled: isScrolled, onBack: {},
                    trailing: { Button("More") {} }
                )
                expectBounds(bare, width: width)
                expectBounds(actions, width: width)
            }
        }
    }

    private func expectBounds(_ content: some View, width: CGFloat) {
        let controller = UIHostingController(rootView: content)
        controller.view.frame = CGRect(x: 0, y: 0, width: width, height: 800)
        controller.view.layoutIfNeeded()
        let size = controller.sizeThatFits(in: CGSize(width: width, height: 800))
        #expect(size.width <= width + 1)
        #expect(abs(size.height - CustomSizes.Header.height.scaledToArtwork) <= 1)
    }
}
