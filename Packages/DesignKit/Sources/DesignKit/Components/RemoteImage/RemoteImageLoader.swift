//
//  RemoteImageLoader.swift
//  DesignKit
//
//  Created by Wendra on 27/10/26.
//

import UIKit

/// Mengunduh gambar dari URL dan menyimpannya di memori agar tidak diunduh ulang setiap tampil.
/// Permintaan ke URL yang sama selagi masih berjalan digabung menjadi satu unduhan.
/// Cache memori dilepas sistem saat memori menipis; `URLSession.shared` tetap memakai `URLCache`
/// bawaan (disk) sesuai header HTTP server. Unduhan gagal tidak disimpan, jadi tampil berikutnya mencoba lagi.
public actor RemoteImageLoader {
    /// Dipakai bersama seluruh halaman agar gambar yang sama hanya diunduh sekali per sesi aplikasi.
    public static let shared = RemoteImageLoader()
    private nonisolated let cache = ImageMemoryCache()
    private let fetch: @Sendable (URL) async throws -> Data
    private var downloads: [URL: Task<UIImage?, Never>] = [:]

    /// `fetch` bisa diganti di test; bawaannya `URLSession.shared`.
    public init(fetch: @escaping @Sendable (URL) async throws -> Data = RemoteImageLoader.download) {
        self.fetch = fetch
    }

    /// Gambar yang sudah ada di memori, tanpa menunggu. Dipakai agar gambar tidak berkedip saat view dibuat ulang.
    public nonisolated func cachedImage(for url: URL) -> UIImage? {
        cache.image(for: url)
    }

    /// Gambar dari memori, atau unduh lalu simpan. Nil bila unduhan gagal atau datanya bukan gambar.
    public func image(for url: URL) async -> UIImage? {
        if let cached = cachedImage(for: url) { return cached }
        if let running = downloads[url] { return await running.value }
        let download = Task.detached { [fetch] in
            (try? await fetch(url)).flatMap { UIImage(data: $0) }
        }
        downloads[url] = download
        let image = await download.value
        downloads[url] = nil
        if let image { cache.store(image, for: url) }
        return image
    }
}

// MARK: - Helpers

public extension RemoteImageLoader {
    @Sendable
    static func download(_ url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
