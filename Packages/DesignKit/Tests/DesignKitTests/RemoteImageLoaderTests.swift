//
//  RemoteImageLoaderTests.swift
//  DesignKit
//
//  Created by Wendra on 27/10/26.
//

import Foundation
import Testing
import UIKit

@testable import DesignKit

struct RemoteImageLoaderTests {
    private let url = URL(fileURLWithPath: "/icons/portfolio.png")
    private let iconPixels = 72

    @Test
    func secondRequestComesFromMemoryWithoutDownloadingAgain() async throws {
        let counter = DownloadCounter()
        let data = try #require(Self.imageData(side: 2))
        let loader = RemoteImageLoader { _ in
            _ = await counter.increment()
            return data
        }
        #expect(loader.cachedImage(for: url, maxPixelSize: iconPixels) == nil)
        #expect(await loader.image(for: url, maxPixelSize: iconPixels) != nil)
        #expect(await loader.image(for: url, maxPixelSize: iconPixels) != nil)
        #expect(loader.cachedImage(for: url, maxPixelSize: iconPixels) != nil)
        #expect(await counter.count == 1)
    }

    @Test
    func concurrentRequestsForOneURLShareOneDownload() async throws {
        let counter = DownloadCounter()
        let data = try #require(Self.imageData(side: 2))
        let loader = RemoteImageLoader { _ in
            _ = await counter.increment()
            try await Task.sleep(nanoseconds: 50_000_000)
            return data
        }
        async let first = loader.image(for: url, maxPixelSize: iconPixels)
        async let second = loader.image(for: url, maxPixelSize: iconPixels)
        async let third = loader.image(for: url, maxPixelSize: iconPixels)
        let images = await [first, second, third]
        #expect(images.allSatisfy { $0 != nil })
        #expect(await counter.count == 1)
    }

    @Test
    func failedDownloadIsNotCachedSoTheNextRequestRetries() async throws {
        let counter = DownloadCounter()
        let data = try #require(Self.imageData(side: 2))
        let loader = RemoteImageLoader { _ in
            guard await counter.increment() > 1 else { throw URLError(.notConnectedToInternet) }
            return data
        }
        #expect(await loader.image(for: url, maxPixelSize: iconPixels) == nil)
        #expect(loader.cachedImage(for: url, maxPixelSize: iconPixels) == nil)
        #expect(await loader.image(for: url, maxPixelSize: iconPixels) != nil)
        #expect(await counter.count == 2)
    }

    @Test
    func dataThatIsNotAnImageGivesNil() async {
        let loader = RemoteImageLoader { _ in Data("not an image".utf8) }
        #expect(await loader.image(for: url, maxPixelSize: iconPixels) == nil)
        #expect(loader.cachedImage(for: url, maxPixelSize: iconPixels) == nil)
    }

    /// Server/CDN bisa membalas 503 dengan body gambar; itu tetap gagal agar tidak tersimpan di cache.
    @Test(arguments: [404, 500, 503])
    func errorStatusIsRejectedEvenWhenTheBodyIsAnImage(statusCode: Int) throws {
        let data = try #require(Self.imageData(side: 2))
        let response = try #require(
            HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil))
        #expect(throws: URLError.self) { try RemoteImageLoader.validated(data, response: response) }
    }

    @Test
    func successStatusAndLocalFilesPassTheirData() throws {
        let data = try #require(Self.imageData(side: 2))
        let success = try #require(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil))
        let local = URLResponse(url: url, mimeType: nil, expectedContentLength: data.count, textEncodingName: nil)
        #expect(try RemoteImageLoader.validated(data, response: success) == data)
        #expect(try RemoteImageLoader.validated(data, response: local) == data)
    }

    /// Ikon 2048×2048 dari server disimpan seukuran tampilnya, bukan bitmap penuh (~16 MiB).
    @Test
    func largeImageIsDownsampledAndSmallImageIsNotEnlarged() async throws {
        let large = try #require(Self.imageData(side: 2048))
        let small = try #require(Self.imageData(side: 2))
        let largeImage = try #require(RemoteImageLoader.decode(large, maxPixelSize: iconPixels)?.cgImage)
        let smallImage = try #require(RemoteImageLoader.decode(small, maxPixelSize: iconPixels)?.cgImage)
        #expect(max(largeImage.width, largeImage.height) == iconPixels)
        #expect(largeImage.bytesPerRow * largeImage.height < 1024 * 1024)
        #expect(smallImage.width == 2)
    }

    @Test
    func sameURLAtAnotherSizeIsCachedSeparately() async throws {
        let data = try #require(Self.imageData(side: 512))
        let loader = RemoteImageLoader { _ in data }
        let icon = try #require(await loader.image(for: url, maxPixelSize: iconPixels)?.cgImage)
        let banner = try #require(await loader.image(for: url, maxPixelSize: 256)?.cgImage)
        #expect(icon.width == iconPixels)
        #expect(banner.width == 256)
        #expect(loader.cachedImage(for: url, maxPixelSize: iconPixels)?.cgImage?.width == iconPixels)
    }
}

// MARK: - Helpers

private extension RemoteImageLoaderTests {
    static func imageData(side: CGFloat) -> Data? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let size = CGSize(width: side, height: side)
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        .pngData()
    }
}
