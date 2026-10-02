import SwiftUI
import UIKit

/// All states reserve the same space. A view-owned task cancels on removal.
struct RemoteImage: View {
    let url: URL?
    let aspectRatio: Double
    @Environment(\.theme) private var theme
    @Environment(\.imageLoader) private var loader
    @State private var loaded: LoadedImage?

    var body: some View {
        Color.clear
            .aspectRatio(aspectRatio.isFinite && aspectRatio > 0 ? aspectRatio : 1, contentMode: .fit)
            .overlay(content)
            .clipped()
            .task(id: request) { await load() }
    }

    private var request: ImageRequest {
        ImageRequest(url: url, loader: ObjectIdentifier(loader))
    }

    @ViewBuilder
    private var content: some View {
        if let image = currentImage {
            Image(uiImage: image).resizable().scaledToFill()
        } else {
            Rectangle().fill(Color(theme.colors.surface))
        }
    }

    private var currentImage: UIImage? {
        if loaded?.request == request { return loaded?.image }
        return url.flatMap { loader.cachedImage(for: $0) }
    }

    @MainActor
    private func load() async {
        let current = request
        loaded = nil
        guard let url else { return }
        let image = await loader.image(from: url)
        guard !Task.isCancelled else { return }
        loaded = LoadedImage(request: current, image: image)
    }
}

private struct ImageRequest: Equatable {
    let url: URL?
    let loader: ObjectIdentifier
}

private struct LoadedImage {
    let request: ImageRequest
    let image: UIImage?
}
