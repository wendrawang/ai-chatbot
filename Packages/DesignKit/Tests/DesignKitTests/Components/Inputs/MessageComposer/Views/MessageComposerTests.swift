//
//  MessageComposerTests.swift
//  DesignKit
//
//  Created by Wendra on 10/11/26.
//

import SwiftUI
import Testing
import UIKit

@testable import DesignKit

/// Tinggi composer: tombol lampiran tidak menambah tinggi; placeholder panjang paling banyak dua baris.
@MainActor
struct MessageComposerTests {
    @Test
    func attachmentKeepsTheComposerHeight() throws {
        try FontFace.registerFonts()
        let plain = size(of: composer(attachment: nil))
        let attached = size(of: composer(attachment: MessageComposerAttachment(label: "Lampirkan") {}))
        #expect(abs(attached.height - plain.height) <= 0.5)
    }

    /// Placeholder panjang turun ke baris kedua lalu dipotong; begitu ada ketikan satu baris, composer kembali pendek.
    @Test
    func longPlaceholderWrapsToTwoLinesOnlyWhileEmpty() throws {
        try FontFace.registerFonts()
        let sentence = "Tanya seputar keuangan & layanan OCBC "
        let short = size(of: composer(placeholder: "Tanya"))
        let wrapped = size(of: composer(placeholder: String(repeating: sentence, count: 2)))
        let clipped = size(of: composer(placeholder: String(repeating: sentence, count: 12)))
        let typed = size(of: composer(text: "Halo", placeholder: String(repeating: sentence, count: 12)))
        #expect(wrapped.height > short.height + 1)
        #expect(abs(clipped.height - wrapped.height) <= 0.5)
        #expect(abs(typed.height - short.height) <= 0.5)
    }
}

// MARK: - Helpers

private extension MessageComposerTests {
    func composer(
        text: String = String(),
        placeholder: String = "Tanya",
        attachment: MessageComposerAttachment? = nil
    ) -> some View {
        MessageComposer(
            text: .constant(text), placeholder: placeholder, actionLabel: "Kirim", attachment: attachment, onSend: {}
        )
    }

    func size(of content: some View) -> CGSize {
        UIHostingController(rootView: content).sizeThatFits(in: CGSize(width: 375, height: 800))
    }
}
