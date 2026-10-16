//
//  ScreenHeaderTests.swift
//  DesignKit
//
//  Created by Wendra on 16/10/26.
//

import SwiftUI
import XCTest

@testable import DesignKit

@MainActor
final class ScreenHeaderTests: XCTestCase {
    func testLongTitlesStayWithinCompactWidthsWithAndWithoutTrailingAction() throws {
        try FontFace.registerFonts()
        for width: CGFloat in [320, 375, 430] {
            for isScrolled in [false, true] {
                let title = String(repeating: "Judul panjang 中文 English ", count: 12)
                let bare = ScreenHeader(title: title, backLabel: "Back", isScrolled: isScrolled, onBack: {})
                let actions = ScreenHeader(
                    title: title, backLabel: "Back", isScrolled: isScrolled, onBack: {},
                    trailing: { Button("More") {} }
                )
                assertBounds(bare, width: width)
                assertBounds(actions, width: width)
            }
        }
    }

    private func assertBounds(_ content: some View, width: CGFloat) {
        let controller = UIHostingController(rootView: content)
        controller.view.frame = CGRect(x: 0, y: 0, width: width, height: 800)
        controller.view.layoutIfNeeded()
        let size = controller.sizeThatFits(in: CGSize(width: width, height: 800))
        XCTAssertLessThanOrEqual(size.width, width + 1)
        XCTAssertEqual(size.height, CustomSizes.Header.height.scaledToArtwork, accuracy: 1)
    }
}
