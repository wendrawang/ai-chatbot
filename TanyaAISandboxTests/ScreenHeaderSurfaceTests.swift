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
        func headerIsTransparentAtRestAndLiftedByShadowWhenScrolled() throws {
            let height = ScreenHeader.height(isNotched: true)
            let reach = CustomSizes.Shadow.radius.scaledToArtwork + CustomSizes.Shadow.offsetY.scaledToArtwork
            let atRest = try render(isScrolled: false)
            let scrolled = try render(isScrolled: true)
            // Header: padding kiri, jauh dari tombol back. Bayangan: tengah layar, jauh dari tepi yang memudar.
            let inHeader = height / 2
            let inShadow = height + CustomSizes.Shadow.offsetY.scaledToArtwork
            let belowShadow = height + reach * 2
            let middle = scrolled.width / 2

            #expect(isBackdrop(try atRest.pixel(atHeaderOffset: inHeader)), "header harus transparan saat diam")
            #expect(isBackdrop(try atRest.pixel(atHeaderOffset: inShadow, column: middle)), "tanpa bayangan saat diam")
            #expect(isSurface(try scrolled.pixel(atHeaderOffset: inHeader)), "header harus putih saat digulir")
            let shadow = try scrolled.pixel(atHeaderOffset: inShadow, column: middle)
            #expect(!(isBackdrop(shadow) || isSurface(shadow)), "bayangan harus terlihat di bawah header: \(shadow)")
            let below = try scrolled.pixel(atHeaderOffset: belowShadow, column: middle)
            #expect(isBackdrop(below), "bayangan tidak menjalar: \(below)")
        }
    }
}

// MARK: - Helpers

private struct RenderedHeader {
    let image: CGImage
    let scale: CGFloat
    let headerTop: CGFloat

    var width: CGFloat { CGFloat(image.width) / scale }

    func pixel(atHeaderOffset offset: CGFloat, column: CGFloat = 2) throws -> [UInt8] {
        let point = CGRect(x: column * scale, y: (headerTop + offset) * scale, width: 1, height: 1)
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
            ScreenHeader(title: "Judul", backLabel: "Back", isScrolled: isScrolled, isNotched: true, onBack: {})
        }
        .ignoresSafeArea(.container, edges: .top)
        let fixture = try HostWindowFixture(content)
        defer { fixture.close() }
        let window = try #require(fixture.controller.view.window)
        let image = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        #expect(ScreenHeader.isNotched(safeAreaTop: window.safeAreaInsets.top), "simulator test harus ber-notch")
        return RenderedHeader(image: try #require(image.cgImage), scale: image.scale, headerTop: .zero)
    }

    func isBackdrop(_ rgba: [UInt8]) -> Bool {
        rgba[0] > 240 && rgba[1] < 15 && rgba[2] < 15
    }

    func isSurface(_ rgba: [UInt8]) -> Bool {
        rgba[0] > 240 && rgba[1] > 240 && rgba[2] > 240
    }
}
