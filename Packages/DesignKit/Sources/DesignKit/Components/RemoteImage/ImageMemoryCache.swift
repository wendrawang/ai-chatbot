//
//  ImageMemoryCache.swift
//  DesignKit
//
//  Created by Wendra on 27/10/26.
//

import UIKit

/// Penyimpanan gambar di memori per URL dan ukuran. `NSCache` aman dipakai dari thread mana pun
/// (dokumentasi Apple), jadi aman dibaca langsung tanpa menunggu actor. Biaya tiap gambar = ukuran
/// bitmap-nya; total dibatasi `RemoteImageLimits.memoryCostLimit` dan dilepas saat memori menipis.
struct ImageMemoryCache: @unchecked Sendable {
    private let storage = NSCache<ImageCacheKey, UIImage>()

    init(costLimit: Int = RemoteImageLimits.memoryCostLimit) {
        storage.totalCostLimit = costLimit
    }

    func image(for key: ImageCacheKey) -> UIImage? {
        storage.object(forKey: key)
    }

    func store(_ image: UIImage, for key: ImageCacheKey) {
        let cost = image.cgImage.map { $0.bytesPerRow * $0.height } ?? .zero
        storage.setObject(image, forKey: key, cost: cost)
    }
}
