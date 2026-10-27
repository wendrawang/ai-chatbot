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

    @Test
    func secondRequestComesFromMemoryWithoutDownloadingAgain() async throws {
        let counter = DownloadCounter()
        let data = try #require(Self.imageData)
        let loader = RemoteImageLoader { _ in
            _ = await counter.increment()
            return data
        }
        #expect(loader.cachedImage(for: url) == nil)
        #expect(await loader.image(for: url) != nil)
        #expect(await loader.image(for: url) != nil)
        #expect(loader.cachedImage(for: url) != nil)
        #expect(await counter.count == 1)
    }

    @Test
    func concurrentRequestsForOneURLShareOneDownload() async throws {
        let counter = DownloadCounter()
        let data = try #require(Self.imageData)
        let loader = RemoteImageLoader { _ in
            _ = await counter.increment()
            try await Task.sleep(nanoseconds: 50_000_000)
            return data
        }
        async let first = loader.image(for: url)
        async let second = loader.image(for: url)
        async let third = loader.image(for: url)
        let images = await [first, second, third]
        #expect(images.allSatisfy { $0 != nil })
        #expect(await counter.count == 1)
    }

    @Test
    func failedDownloadIsNotCachedSoTheNextRequestRetries() async throws {
        let counter = DownloadCounter()
        let data = try #require(Self.imageData)
        let loader = RemoteImageLoader { _ in
            guard await counter.increment() > 1 else { throw URLError(.notConnectedToInternet) }
            return data
        }
        #expect(await loader.image(for: url) == nil)
        #expect(loader.cachedImage(for: url) == nil)
        #expect(await loader.image(for: url) != nil)
        #expect(await counter.count == 2)
    }

    @Test
    func dataThatIsNotAnImageGivesNil() async {
        let loader = RemoteImageLoader { _ in Data("not an image".utf8) }
        #expect(await loader.image(for: url) == nil)
        #expect(loader.cachedImage(for: url) == nil)
    }
}

// MARK: - Helpers

private extension RemoteImageLoaderTests {
    static var imageData: Data? {
        UIGraphicsImageRenderer(size: CGSize(width: 2, height: 2)).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 2, height: 2))
        }
        .pngData()
    }
}
