//
//  RemoteImageTests.swift
//  DesignKit
//
//  Created by Wendra on 27/10/26.
//

import SwiftUI
import Testing
import UIKit

@testable import DesignKit

/// Berurutan karena setiap test membuka window dan menunggu hasil unduhan.
@MainActor
@Suite(.serialized)
struct RemoteImageTests {
    private let url = URL(fileURLWithPath: "/icons/valas.png")

    @Test
    func failedDownloadReplacesThePlaceholderWithTheFallback() async {
        var isPlaceholderShown = false
        var isFallbackShown = false
        let loader = RemoteImageLoader { _ in throw URLError(.cannotFindHost) }
        let window = show(
            RemoteImage(
                url: url, loader: loader,
                placeholder: { Color.clear.onAppear { isPlaceholderShown = true } },
                fallback: { Color.clear.onAppear { isFallbackShown = true } }
            )
        )
        defer { window.isHidden = true }
        #expect(isPlaceholderShown)
        await waitUntil { isFallbackShown }
    }

    @Test
    func missingURLShowsTheFallbackWithoutLoading() async {
        var isPlaceholderShown = false
        var isFallbackShown = false
        let counter = DownloadCounter()
        let loader = RemoteImageLoader { _ in
            _ = await counter.increment()
            return Data()
        }
        let window = show(
            RemoteImage(
                url: nil, loader: loader,
                placeholder: { Color.clear.onAppear { isPlaceholderShown = true } },
                fallback: { Color.clear.onAppear { isFallbackShown = true } }
            )
        )
        defer { window.isHidden = true }
        await waitUntil { isFallbackShown }
        #expect(!isPlaceholderShown)
        #expect(await counter.count == 0)
    }

    @Test
    func loadedImageNeverShowsTheFallback() async throws {
        var isFallbackShown = false
        let data = try #require(Self.imageData)
        let loader = RemoteImageLoader { _ in data }
        let window = show(
            RemoteImage(
                url: url, loader: loader, placeholder: { Color.clear },
                fallback: { Color.clear.onAppear { isFallbackShown = true } }
            )
        )
        defer { window.isHidden = true }
        await waitUntil { loader.cachedImage(for: url) != nil }
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(!isFallbackShown)
    }
}

// MARK: - Helpers

private extension RemoteImageTests {
    static var imageData: Data? {
        UIGraphicsImageRenderer(size: CGSize(width: 2, height: 2)).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 2, height: 2))
        }
        .pngData()
    }

    func show(_ content: some View) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.rootViewController = UIHostingController(rootView: content.frame(width: 24, height: 24))
        window.makeKeyAndVisible()
        window.rootViewController?.view.layoutIfNeeded()
        return window
    }
}
