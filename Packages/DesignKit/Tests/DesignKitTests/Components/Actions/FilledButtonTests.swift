//
//  FilledButtonTests.swift
//  DesignKitTests
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI
import Testing
import UIKit

@testable import DesignKit

/// Tombol selebar wadah; tingginya teks ditambah padding atas-bawah varian masing-masing. Varian `.link`
/// menggantikan `FilledLinkButton` dengan ukuran yang sama.
@MainActor
struct FilledButtonTests {
    private let width: CGFloat = 343

    @Test
    func theRegularButtonSpansItsContainer() throws {
        try FontFace.registerFonts()
        let button = size(of: FilledButton(title: "Konfirmasi") {})
        let text = size(of: label("Konfirmasi", size: FigmaSize.typographySizeDisplaySmall14))
        let padding = CustomSizes.FilledButton.verticalPadding.scaledToArtwork * 2
        #expect(abs(button.width - width) <= 0.5)
        #expect(abs(button.height - text.height - padding) <= 0.5)
    }

    @Test
    func theLinkButtonKeepsTheSizeOfTheFormerLinkButton() throws {
        try FontFace.registerFonts()
        let button = size(of: FilledButton(title: "Batalkan proses ini", variant: .link) {})
        let text = size(of: label("Batalkan proses ini", size: FigmaSize.typographySizeDisplayTiny12))
        #expect(abs(button.width - width) <= 0.5)
        #expect(abs(button.height - text.height - FigmaSize.spacingMedium.scaledToArtwork * 2) <= 0.5)
    }
}

// MARK: - Helpers

private extension FilledButtonTests {
    func label(_ title: String, size: CGFloat) -> some View {
        Text(title).font(FontFace.firaSansSemiBold.swiftUIFont(size: size.scaledToArtwork))
    }

    func size(of content: some View) -> CGSize {
        UIHostingController(rootView: content).sizeThatFits(in: CGSize(width: width, height: 800))
    }
}
