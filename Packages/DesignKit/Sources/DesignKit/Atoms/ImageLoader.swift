import Foundation
import ImageIO
import UIKit

enum ImageLoader {
    // Covers the 320-point bubble at 3x without retaining full camera images.
    static let maximumPixelSize = 1_024

    /// A nonisolated async function keeps ImageIO decoding off the UI actor.
    /// Downloading to a file avoids retaining the compressed response in RAM.
    static func image(from url: URL) async -> UIImage? {
        do {
            let (fileURL, response) = try await URLSession.shared.download(from: url)
            defer { try? FileManager.default.removeItem(at: fileURL) }
            try Task.checkCancellation()
            guard let response = response as? HTTPURLResponse,
                  (200..<300).contains(response.statusCode),
                  let image = thumbnail(at: fileURL) else { return nil }
            try Task.checkCancellation()
            ImageCache.shared.store(image, for: url)
            return image
        } catch {
            // A failed or cancelled image keeps the existing placeholder.
            return nil
        }
    }

    static func thumbnail(at fileURL: URL) -> UIImage? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithURL(fileURL as CFURL, sourceOptions) else {
            return nil
        }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maximumPixelSize,
            kCGImageSourceShouldCacheImmediately: true
        ]
        guard let bitmap = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }
        return UIImage(cgImage: bitmap)
    }
}
