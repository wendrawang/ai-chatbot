//
//  FileCardTests.swift
//  DesignKit
//
//  Created by Wendra on 27/11/26.
//

import SwiftUI
import Testing
import UIKit

@testable import DesignKit

/// Kartu file selebar token dan setinggi yang sama di setiap status, supaya daftar pesan tidak bergeser saat status
/// berganti; nama panjang tetap satu baris.
@MainActor
struct FileCardTests {
    @Test
    func everyStatusKeepsTheSameSize() throws {
        try FontFace.registerFonts()
        let sending = size(of: FileCard(name: "Slip.pdf", status: .sending(note: "Mengirim…")) {})
        let ready = size(of: FileCard(name: "Slip.pdf", status: .ready(note: "PDF", action: "Lihat Detail")) {})
        let failed = size(of: FileCard(name: "Slip.pdf", status: .failed(note: "Gagal", action: "Coba lagi")) {})
        #expect(sending.width == CustomSizes.FileCard.width.scaledToArtwork)
        #expect(ready == sending)
        #expect(failed == sending)
    }

    @Test
    func longNameStaysOnOneLine() throws {
        try FontFace.registerFonts()
        let status = FileCardStatus.ready(note: "PDF", action: "Lihat Detail")
        let short = size(of: FileCard(name: "Slip.pdf", status: status) {})
        let long = size(
            of: FileCard(name: String(repeating: "Slip gaji Oktober ", count: 6) + ".pdf", status: status) {})
        #expect(long == short)
    }
}

// MARK: - Helpers

private extension FileCardTests {
    func size(of content: some View) -> CGSize {
        UIHostingController(rootView: content).sizeThatFits(in: CGSize(width: 375, height: 2_000))
    }
}
