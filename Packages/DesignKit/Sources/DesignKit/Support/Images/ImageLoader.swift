import Foundation
import ImageIO
import UIKit

/// Inject a separate loader for each authenticated scope or a pinned URLSession.
public protocol ImageLoading: AnyObject {
    func cachedImage(for url: URL) -> UIImage?
    func image(from url: URL) async -> UIImage?
}

public final class ImageLoader: ImageLoading {
    public static let shared = ImageLoader()
    static let maximumPixelSize = 1_024
    private let session: URLSession
    private let pixelLimit: Int
    private let cache = NSCache<NSURL, UIImage>()
    private let lock = NSLock()
    private var generation = 0

    /// The session remains owned by the caller; clearing never invalidates it.
    public init(session: URLSession = .shared, maximumPixelSize: Int = 1_024) {
        self.session = session
        pixelLimit = min(4_096, max(1, maximumPixelSize))
        cache.countLimit = 40
        cache.totalCostLimit = 32 * 1_024 * 1_024
    }

    public func cachedImage(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    /// Removes decoded images and prevents older requests from refilling this cache.
    /// Hosts also clear their URLCache when ending an authenticated session.
    public func removeAllImages() {
        lock.lock()
        defer { lock.unlock() }
        generation += 1
        cache.removeAllObjects()
    }

    public func image(from url: URL) async -> UIImage? {
        guard !Task.isCancelled else { return nil }
        if let cached = cachedImage(for: url) { return cached }
        let requestGeneration = currentGeneration()
        do {
            let (fileURL, response) = try await session.download(from: url)
            defer { try? FileManager.default.removeItem(at: fileURL) }
            try Task.checkCancellation()
            guard let response = response as? HTTPURLResponse,
                  (200..<300).contains(response.statusCode),
                  let image = Self.thumbnail(at: fileURL, maximumPixelSize: pixelLimit) else { return nil }
            try Task.checkCancellation()
            return store(image, for: url, generation: requestGeneration) ? image : nil
        } catch {
            return nil
        }
    }

    private func currentGeneration() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return generation
    }

    private func store(_ image: UIImage, for url: URL, generation requestGeneration: Int) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard generation == requestGeneration, let bitmap = image.cgImage else { return false }
        cache.setObject(image, forKey: url as NSURL, cost: bitmap.bytesPerRow * bitmap.height)
        return true
    }

    static func thumbnail(at fileURL: URL, maximumPixelSize: Int = maximumPixelSize) -> UIImage? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithURL(fileURL as CFURL, sourceOptions) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maximumPixelSize,
            kCGImageSourceShouldCacheImmediately: true
        ]
        guard let bitmap = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        return UIImage(cgImage: bitmap)
    }
}
