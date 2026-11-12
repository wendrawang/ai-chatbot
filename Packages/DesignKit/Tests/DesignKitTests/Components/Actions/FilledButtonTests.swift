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

/// Tombol selebar wadah, tingginya teks ditambah jarak atas-bawah.
@MainActor
struct FilledButtonTests {
    @Test
    func theButtonSpansItsContainer() throws {
        try FontFace.registerFonts()
        let size = UIHostingController(rootView: FilledButton(title: "Konfirmasi") {})
            .sizeThatFits(in: CGSize(width: 343, height: 800))
        let label = UIHostingController(
            rootView: Text("Konfirmasi")
                .font(
                    FontFace.firaSansSemiBold.swiftUIFont(size: FigmaSize.typographySizeDisplaySmall14.scaledToArtwork))
        )
        .sizeThatFits(in: CGSize(width: 343, height: 800))
        let padding = CustomSizes.FilledButton.verticalPadding.scaledToArtwork * 2
        #expect(abs(size.width - 343) <= 0.5)
        #expect(abs(size.height - label.height - padding) <= 0.5)
    }
}
