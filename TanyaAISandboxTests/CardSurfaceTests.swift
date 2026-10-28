//
//  CardSurfaceTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 28/10/26.
//

import DesignKit
import SwiftUI
import Testing
import UIKit

extension HostWindowTests {
    /// Diuji di app host karena warna piksel hanya bisa dibaca dari window dengan scene sungguhan.
    @MainActor
    struct CardSurfaceTests {
        /// Tepi kiri kartu: garis `Stroke` bila outlined, putih isi kartu bila hanya bayangan (ActionCard).
        @Test
        func outlineIsDrawnOnlyWhenRequested() throws {
            let outlined = try edgePixel(isOutlined: true)
            let shadowOnly = try edgePixel(isOutlined: false)
            #expect(outlined.allSatisfy { $0 < 245 }, "garis tepi harus terlihat: \(outlined)")
            #expect(shadowOnly.allSatisfy { $0 > 250 }, "tanpa garis tepi, tepi kartu tetap putih: \(shadowOnly)")
        }
    }
}

// MARK: - Helpers

private extension HostWindowTests.CardSurfaceTests {
    /// RGB piksel di kolom paling kiri kartu, setengah tinggi kartu.
    func edgePixel(isOutlined: Bool) throws -> [UInt8] {
        let margin: CGFloat = 40
        let card = CGSize(width: 160, height: 80)
        let content = ZStack(alignment: .topLeading) {
            Color.white.ignoresSafeArea()
            Color.clear.frame(width: card.width, height: card.height)
                .cardStyle(isOutlined: isOutlined)
                .padding(margin)
        }
        let fixture = try HostWindowFixture(content)
        defer { fixture.close() }
        let window = try #require(fixture.controller.view.window)
        let origin = fixture.controller.view.safeAreaInsets.top + margin
        let image = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        let cgImage = try #require(image.cgImage)
        let point = CGRect(
            x: (margin + 0.5) * image.scale, y: (origin + card.height / 2) * image.scale, width: 1, height: 1
        )
        let crop = try #require(cgImage.cropping(to: point.integral))
        var data = [UInt8](repeating: .zero, count: 4)
        let context = try #require(
            CGContext(
                data: &data, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
                space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        )
        context.draw(crop, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        return Array(data.prefix(3))
    }
}
