//
//  TextChipTests.swift
//  DesignKit
//
//  Created by Wendra on 3/11/26.
//

import SwiftUI
import Testing
import UIKit

@testable import DesignKit

/// Chip selebar isinya dengan padding token; satu baris walau teksnya panjang.
@MainActor
struct TextChipTests {
    private let label = "14 Okt 2026"

    @Test
    func chipHugsItsTextAndAddsOnlyItsPadding() throws {
        try FontFace.registerFonts()
        let chip = size(of: TextChip(text: label), width: 375)
        let text = size(of: Text(label).font(font), width: 375)
        #expect(abs(chip.width - text.width - FigmaSize.spacingMedium.scaledToArtwork * 2) <= 0.5)
        #expect(abs(chip.height - text.height - FigmaSize.spacingSmall.scaledToArtwork * 2) <= 0.5)
    }

    @Test
    func longTextStaysOnOneLine() throws {
        try FontFace.registerFonts()
        let short = size(of: TextChip(text: label), width: 120)
        let long = size(of: TextChip(text: String(repeating: label + " ", count: 8)), width: 120)
        #expect(abs(long.height - short.height) <= 0.5)
    }
}

// MARK: - Helpers

private extension TextChipTests {
    var font: Font {
        FontFace.firaSansRegular.swiftUIFont(size: FigmaSize.typographySizeDisplayTiny12.scaledToArtwork)
    }

    func size(of content: some View, width: CGFloat) -> CGSize {
        UIHostingController(rootView: content).sizeThatFits(in: CGSize(width: width, height: 800))
    }
}
