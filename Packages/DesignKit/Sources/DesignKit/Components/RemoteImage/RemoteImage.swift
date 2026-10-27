//
//  RemoteImage.swift
//  DesignKit
//
//  Created by Wendra on 27/10/26.
//

import SwiftUI

/// Gambar dari URL dengan cache memori `RemoteImageLoader`. Gambar yang sudah tersimpan langsung tampil
/// tanpa berkedip. `placeholder` tampil selama mengunduh; `fallback` tampil bila URL kosong/tidak valid,
/// unduhan gagal, atau data bukan gambar. Kegagalan tidak di-cache, jadi tampil berikutnya mencoba lagi.
/// `pointSize` adalah sisi terpanjang ukuran tampil; gambar di-downsample ke ukuran itu × skala layar.
@MainActor
public struct RemoteImage<Placeholder: View, Fallback: View>: View {
    @Environment(\.displayScale)
    private var displayScale
    @State
    private var loadedURL: URL?
    @State
    private var loadedImage: UIImage?
    private let url: URL?
    private let pointSize: CGFloat
    private let loader: RemoteImageLoader
    private let placeholder: Placeholder
    private let fallback: Fallback

    public init(
        url: URL?, pointSize: CGFloat, loader: RemoteImageLoader = .shared,
        @ViewBuilder placeholder: () -> Placeholder, @ViewBuilder fallback: () -> Fallback
    ) {
        self.url = url
        self.pointSize = pointSize
        self.loader = loader
        self.placeholder = placeholder()
        self.fallback = fallback()
    }

    public var body: some View {
        content
            .task(id: url) { await load() }
    }

    @ViewBuilder
    private var content: some View {
        if let image = currentImage {
            Image(uiImage: image).resizable().scaledToFit()
        } else if isFailed {
            fallback
        } else {
            placeholder
        }
    }
}

// MARK: - Helpers

private extension RemoteImage {
    var maxPixelSize: Int { Int((pointSize * displayScale).rounded(.up)) }

    /// Hasil unduhan untuk URL saat ini, atau yang sudah ada di cache dari tampilan sebelumnya.
    var currentImage: UIImage? {
        guard let url else { return nil }
        if loadedURL == url, let loadedImage { return loadedImage }
        return loader.cachedImage(for: url, maxPixelSize: maxPixelSize)
    }

    /// Tidak ada URL, atau unduhan untuk URL ini sudah selesai tanpa gambar.
    var isFailed: Bool {
        guard let url else { return true }
        return loadedURL == url && loadedImage == nil
    }

    func load() async {
        guard let url else { return }
        let image = await loader.image(for: url, maxPixelSize: maxPixelSize)
        guard !Task.isCancelled else { return }
        loadedURL = url
        loadedImage = image
    }
}
