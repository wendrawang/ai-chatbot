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
/// menggantikan `FilledLinkButton` dengan ukuran yang sama; `.outlined` seukuran `.regular` tanpa latar gelap.
/// `.disabled` dari parent tampil sama dengan `isEnabled: false`.
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

    @Test
    func theOutlinedButtonHasTheRegularSizeWithoutTheDarkFill() throws {
        try FontFace.registerFonts()
        let outlined = FilledButton(title: "Batalkan", variant: .outlined) {}
        let regular = FilledButton(title: "Batalkan") {}
        #expect(size(of: outlined) == size(of: regular))
        let outlinedImage = RenderedImage.png(of: outlined, width: width)
        try #require(outlinedImage != nil)
        #expect(outlinedImage != RenderedImage.png(of: regular, width: width))
    }

    @Test
    func aDisabledParentGreysTheOutlinedButtonLikeItsOwnFlag() throws {
        try FontFace.registerFonts()
        let disabled = FilledButton(title: "Batalkan", variant: .outlined, isEnabled: false) {}
        let button = FilledButton(title: "Batalkan", variant: .outlined) {}
        let own = RenderedImage.png(of: disabled, width: width)
        let parent = RenderedImage.png(of: button.disabled(true), width: width)
        let enabled = RenderedImage.png(of: button, width: width)
        try #require(own != nil)
        #expect(parent == own)
        #expect(parent != enabled)
    }

    @Test
    func aDisabledParentGreysTheButtonLikeItsOwnFlag() throws {
        try FontFace.registerFonts()
        let own = RenderedImage.png(of: FilledButton(title: "Pilih", isEnabled: false) {}, width: width)
        let parent = RenderedImage.png(of: FilledButton(title: "Pilih") {}.disabled(true), width: width)
        let enabled = RenderedImage.png(of: FilledButton(title: "Pilih") {}, width: width)
        try #require(own != nil)
        #expect(parent == own)
        #expect(parent != enabled)
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
