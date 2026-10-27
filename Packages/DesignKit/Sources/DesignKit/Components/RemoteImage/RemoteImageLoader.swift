//
//  RemoteImageLoader.swift
//  DesignKit
//
//  Created by Wendra on 27/10/26.
//

import ImageIO
import UIKit

/// Mengunduh gambar dari URL dan menyimpannya di memori agar tidak diunduh ulang setiap tampil.
/// Gambar di-downsample ke `maxPixelSize` (ukuran tampil × skala layar), jadi gambar besar dari server
/// tidak disimpan pada resolusi penuh. Permintaan URL dan ukuran yang sama selagi berjalan digabung.
/// `URLSession.shared` tetap memakai `URLCache` bawaan (disk) sesuai header HTTP server.
/// Unduhan gagal (error jaringan, status non-2xx, atau bukan gambar) tidak disimpan, jadi tampil berikutnya
/// mencoba lagi.
public actor RemoteImageLoader {
    /// Dipakai bersama seluruh halaman agar gambar yang sama hanya diunduh sekali per sesi aplikasi.
    public static let shared = RemoteImageLoader()
    private nonisolated let cache = ImageMemoryCache()
    private let fetch: @Sendable (URL) async throws -> Data
    private var downloads: [ImageCacheKey: Task<UIImage?, Never>] = [:]

    /// `fetch` bisa diganti di test; bawaannya `URLSession.shared` dengan validasi status HTTP.
    public init(fetch: @escaping @Sendable (URL) async throws -> Data = RemoteImageLoader.download) {
        self.fetch = fetch
    }

    /// Gambar yang sudah ada di memori, tanpa menunggu. Dipakai agar gambar tidak berkedip saat view dibuat ulang.
    public nonisolated func cachedImage(for url: URL, maxPixelSize: Int) -> UIImage? {
        cache.image(for: ImageCacheKey(url: url, maxPixelSize: maxPixelSize))
    }

    /// Gambar dari memori, atau unduh, downsample, lalu simpan. Nil bila unduhan gagal atau datanya bukan gambar.
    public func image(for url: URL, maxPixelSize: Int) async -> UIImage? {
        let key = ImageCacheKey(url: url, maxPixelSize: maxPixelSize)
        if let cached = cache.image(for: key) { return cached }
        if let running = downloads[key] { return await running.value }
        let download = Task.detached { [fetch] in
            (try? await fetch(url)).flatMap { Self.decode($0, maxPixelSize: maxPixelSize) }
        }
        downloads[key] = download
        let image = await download.value
        downloads[key] = nil
        if let image { cache.store(image, for: key) }
        return image
    }
}

// MARK: - Helpers

public extension RemoteImageLoader {
    @Sendable
    static func download(_ url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        return try validated(data, response: response)
    }

    /// Respons HTTP di luar 2xx dianggap gagal walau body-nya gambar (misalnya halaman error CDN),
    /// agar tidak masuk cache. Respons non-HTTP (file lokal) diteruskan apa adanya.
    static func validated(_ data: Data, response: URLResponse) throws -> Data {
        if let http = response as? HTTPURLResponse,
            !RemoteImageLimits.successStatusCodes.contains(http.statusCode)
        {
            throw URLError(.badServerResponse)
        }
        return data
    }
}

extension RemoteImageLoader {
    /// Decode langsung ke ukuran kecil lewat ImageIO; bitmap penuh tidak pernah dibuat.
    /// Gambar yang sudah lebih kecil dari `maxPixelSize` tidak diperbesar.
    static func decode(_ data: Data, maxPixelSize: Int) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, .zero, options as CFDictionary) else {
            return nil
        }
        return UIImage(cgImage: image)
    }
}
