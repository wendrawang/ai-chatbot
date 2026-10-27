//
//  RenderedHeader.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 22/10/26.
//

import CoreGraphics
import Testing

/// Hasil render header; membaca warna satu piksel di padding kiri.
struct RenderedHeader {
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
