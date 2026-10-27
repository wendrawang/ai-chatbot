//
//  ImageMemoryCache.swift
//  DesignKit
//
//  Created by Wendra on 27/10/26.
//

import UIKit

/// Penyimpanan gambar di memori per URL. `NSCache` aman dipakai dari thread mana pun (dokumentasi Apple)
/// dan otomatis melepas isi saat memori menipis, jadi aman dibaca langsung tanpa menunggu actor.
struct ImageMemoryCache: @unchecked Sendable {
    private let storage = NSCache<NSURL, UIImage>()

    func image(for url: URL) -> UIImage? {
        storage.object(forKey: url as NSURL)
    }

    func store(_ image: UIImage, for url: URL) {
        storage.setObject(image, forKey: url as NSURL)
    }
}
