//
//  ScreenHeaderSurfaceTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 22/10/26.
//

import DesignKit
import SwiftUI
import Testing
import UIKit

extension HostWindowTests {
    /// Diuji di app host karena warna piksel hanya bisa dibaca dari window dengan scene sungguhan.
    @MainActor
    struct ScreenHeaderSurfaceTests {
        @Test
        func headerIsTransparentAtRestAndOpaqueWithFadeWhenScrolled() throws {
            let height = CustomSizes.Header.height.scaledToArtwork
            let fade = FigmaSize.spacingLarge.scaledToArtwork
            let atRest = try render(isScrolled: false)
            let scrolled = try render(isScrolled: true)
            // Titik di padding kiri header, jauh dari tombol back dan judul; y dihitung dari bawah safe area.
            let inHeader = height / 2
            let inFade = height + fade / 2
            let belowFade = height + fade + 4

            #expect(isBackdrop(try atRest.pixel(atHeaderOffset: inHeader)), "header harus transparan saat diam")
            #expect(isBackdrop(try atRest.pixel(atHeaderOffset: inFade)), "tidak ada fade saat diam")
            #expect(isSurface(try scrolled.pixel(atHeaderOffset: inHeader)), "header harus putih saat digulir")
            let fadePixel = try scrolled.pixel(atHeaderOffset: inFade)
            #expect(!(isBackdrop(fadePixel) || isSurface(fadePixel)), "gradient harus di antara putih dan latar")
            #expect(isBackdrop(try scrolled.pixel(atHeaderOffset: belowFade)), "fade hanya setinggi spacingLarge")
        }
    }
}

// MARK: - Helpers

private struct RenderedHeader {
    let image: CGImage
    let scale: CGFloat
    let headerTop: CGFloat

    func pixel(atHeaderOffset offset: CGFloat) throws -> [UInt8] {
        let point = CGRect(x: 2 * scale, y: (headerTop + offset) * scale, width: 1, height: 1)
        let crop = try #require(image.cropping(to: point.integral))
        var data = [UInt8](repeating: .zero, count: 4)
        let context = try #require(
            CGContext(
                data: &data, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
                space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        )
        context.draw(crop, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        return data
    }
}

private extension HostWindowTests.ScreenHeaderSurfaceTests {
    /// Header di atas latar merah, seperti header di atas gambar latar chat.
    func render(isScrolled: Bool) throws -> RenderedHeader {
        let content = ZStack(alignment: .top) {
            Color(red: 1, green: 0, blue: 0).ignoresSafeArea()
            ScreenHeader(title: "Judul", backLabel: "Back", isScrolled: isScrolled, onBack: {})
        }
        let fixture = try HostWindowFixture(content)
        defer { fixture.close() }
        let window = try #require(fixture.controller.view.window)
        let image = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        return RenderedHeader(
            image: try #require(image.cgImage), scale: image.scale, headerTop: window.safeAreaInsets.top
        )
    }

    func isBackdrop(_ rgba: [UInt8]) -> Bool {
        rgba[0] > 240 && rgba[1] < 15 && rgba[2] < 15
    }

    func isSurface(_ rgba: [UInt8]) -> Bool {
        rgba[0] > 240 && rgba[1] > 240 && rgba[2] > 240
    }
}
