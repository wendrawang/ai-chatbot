//
//  ActionCardTests.swift
//  DesignKitTests
//
//  Created by Wendra on 13/11/26.
//

import SwiftUI
import Testing

@testable import DesignKit

/// `.disabled` dari parent membuat chevron abu-abu, sama dengan `isEnabled: false`.
@MainActor
struct ActionCardTests {
    private let width: CGFloat = 343

    @Test
    func aDisabledParentGreysTheCardLikeItsOwnFlag() throws {
        try FontFace.registerFonts()
        let own = RenderedImage.png(of: card(isEnabled: false), width: width)
        try #require(own != nil)
        #expect(RenderedImage.png(of: card(isEnabled: true).disabled(true), width: width) == own)
        #expect(RenderedImage.png(of: card(isEnabled: true), width: width) != own)
    }
}

// MARK: - Helpers

private extension ActionCardTests {
    func card(isEnabled: Bool) -> some View {
        ActionCard(
            title: "Judul",
            description: "Deskripsi",
            isEnabled: isEnabled,
            onTap: {},
            icon: { Color.clear }
        )
    }
}
