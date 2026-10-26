//
//  ComposerActionTests.swift
//  DesignKit
//
//  Created by Wendra on 26/10/26.
//

import SwiftUI
import Testing

@testable import DesignKit

@MainActor
struct ComposerActionTests {
    @Test
    func switchingTheActionKeepsTheComposerSize() throws {
        try FontFace.registerFonts()
        let sizes = [ComposerAction.send, .sending, .stop].map { action in
            size(of: composer(action: action), width: 343)
        }
        #expect(Set(sizes.map(\.height)).count == 1, "\(sizes)")
        #expect(sizes.allSatisfy { $0.width <= 344 })
    }

    @Test
    func loadingDotsFitInsideTheSendButton() {
        let dots = size(of: LoadingDots(color: .clear), width: 375)
        let button = CustomSizes.Composer.sendButton.scaledToArtwork
        #expect(dots.width > 0 && dots.width <= button)
        #expect(dots.height > 0 && dots.height <= button)
    }

    @Test
    func longSuggestionWrapsInsideTheAvailableWidth() throws {
        try FontFace.registerFonts()
        let title = String(repeating: "Cek saldo 中文 ", count: 12)
        let chip = size(of: SuggestionChip(title: title) {}, width: 200)
        #expect(chip.width <= 201)
        #expect(chip.height > CustomSizes.Composer.sendButton.scaledToArtwork)
    }
}

// MARK: - Helpers

private extension ComposerActionTests {
    func composer(action: ComposerAction) -> some View {
        MessageComposer(
            text: .constant("Halo"), placeholder: "Ketik pesan", sendLabel: "Kirim", stopLabel: "Hentikan",
            action: action,
            onSend: {}
        )
    }

    func size(of content: some View, width: CGFloat) -> CGSize {
        let controller = UIHostingController(rootView: content)
        controller.view.frame = CGRect(x: 0, y: 0, width: width, height: 800)
        controller.view.layoutIfNeeded()
        return controller.sizeThatFits(in: CGSize(width: width, height: 800))
    }
}
