//
//  ImageCacheKey.swift
//  DesignKit
//
//  Created by Wendra on 27/10/26.
//

import Foundation

/// Key cache gambar: URL yang sama dengan ukuran tampil berbeda disimpan terpisah karena hasil
/// downsample-nya berbeda. Class `NSObject` karena `NSCache` mewajibkan key berupa object.
final class ImageCacheKey: NSObject, Sendable {
    let url: URL
    let maxPixelSize: Int

    init(url: URL, maxPixelSize: Int) {
        self.url = url
        self.maxPixelSize = maxPixelSize
    }

    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(url)
        hasher.combine(maxPixelSize)
        return hasher.finalize()
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? ImageCacheKey else { return false }
        return url == other.url && maxPixelSize == other.maxPixelSize
    }
}
