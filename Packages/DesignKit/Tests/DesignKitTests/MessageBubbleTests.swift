//
//  MessageBubbleTests.swift
//  DesignKit
//
//  Created by Wendra on 28/10/26.
//

import SwiftUI
import Testing
import UIKit

@testable import DesignKit

/// Bubble keluar memberi padding di dalam surface merah; pesan masuk tanpa background dan tanpa padding.
@MainActor
struct MessageBubbleTests {
    @Test
    func outgoingBubbleAddsVerticalPaddingAroundTheSameText() throws {
        try FontFace.registerFonts()
        let incoming = size(of: MessageBubble(text: "Beli USD", isOutgoing: false))
        let outgoing = size(of: MessageBubble(text: "Beli USD", isOutgoing: true))
        let padding = FigmaSize.spacingMedium.scaledToArtwork * 2
        #expect(abs(outgoing.height - incoming.height - padding) <= 0.5)
    }

    @Test
    func longOutgoingTextWrapsInsideTheLeadingInset() throws {
        try FontFace.registerFonts()
        let width: CGFloat = 375
        let text = String(repeating: "Saya mau beli valas ", count: 15)
        let full = size(of: MessageBubble(text: text, isOutgoing: false), width: width)
        let inset = size(of: MessageBubble(text: text, isOutgoing: true), width: width)
        #expect(inset.height > full.height + FigmaSize.spacingMedium.scaledToArtwork * 2)
    }
}

// MARK: - Helpers

private extension MessageBubbleTests {
    func size(of content: some View, width: CGFloat = 375) -> CGSize {
        UIHostingController(rootView: content).sizeThatFits(in: CGSize(width: width, height: 800))
    }
}
