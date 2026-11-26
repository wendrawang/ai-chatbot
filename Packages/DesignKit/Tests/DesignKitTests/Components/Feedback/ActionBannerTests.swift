//
//  ActionBannerTests.swift
//  DesignKit
//
//  Created by Wendra on 19/11/26.
//

import SwiftUI
import Testing
import UIKit

@testable import DesignKit

/// Bar selebar wadah, dengan atau tanpa tombol; teks panjang menambah tinggi bar, bukan terpotong atau mendorong
/// tombol keluar.
@MainActor
struct ActionBannerTests {
    @Test
    func bannerFillsTheWidthAndGrowsWithItsText() throws {
        try FontFace.registerFonts()
        let short = size(of: banner(text: "Mode agen"))
        let long = size(of: banner(text: String(repeating: "Kamu sedang terhubung dengan agen. ", count: 4)))
        #expect(short.width == width)
        #expect(long.width == width)
        #expect(long.height > short.height)
    }

    /// Tanpa tombol, teks memakai seluruh lebar; tinggi bar tetap mengikuti teks seperti bar bertombol.
    @Test
    func bannerWithoutActionKeepsTheWidthAndGrowsWithItsText() throws {
        try FontFace.registerFonts()
        let short = size(of: ActionBanner(text: "File ditolak", tone: .warning))
        let long = size(
            of: ActionBanner(text: String(repeating: "Ukuran file terlalu besar. ", count: 6), tone: .warning))
        #expect(short.width == width)
        #expect(long.width == width)
        #expect(long.height > short.height)
    }

    /// Snackbar menutupi bar sesi agen, jadi teks satu baris tanpa tombol harus setinggi bar bertombol.
    @Test
    func bannerWithoutActionIsAsTallAsBannerWithAction() throws {
        try FontFace.registerFonts()
        let plain = size(of: ActionBanner(text: "File ditolak", tone: .warning))
        let withAction = size(of: banner(text: "Mode agen"))
        #expect(plain.height == withAction.height)
    }
}

// MARK: - Helpers

private extension ActionBannerTests {
    var width: CGFloat { 375 }

    func banner(text: String) -> some View {
        ActionBanner(text: text, actionTitle: "End Session") {}
    }

    func size(of content: some View) -> CGSize {
        UIHostingController(rootView: content).sizeThatFits(in: CGSize(width: width, height: 2_000))
    }
}
