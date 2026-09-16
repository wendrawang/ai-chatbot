import SwiftUI
import UIKit

/// Keeps decoded images in memory so a cell that scrolls away and back does
/// not blink.
///
/// `URLCache` alone is not enough. It saves the round trip, but a reused cell
/// still starts from an empty view and the picture visibly disappears and
/// returns. Holding the decoded image lets a reused cell render it in the
/// same pass it is configured.
final class ImageCache {
    static let shared = ImageCache()

    private let storage = NSCache<NSURL, UIImage>()

    private init() {
        storage.countLimit = 40
        storage.totalCostLimit = 32 * 1_024 * 1_024
    }

    func image(for url: URL?) -> UIImage? {
        guard let url = url else {
            return nil
        }
        return storage.object(forKey: url as NSURL)
    }

    func store(_ image: UIImage, for url: URL) {
        guard let bitmap = image.cgImage else { return }
        storage.setObject(
            image,
            forKey: url as NSURL,
            cost: bitmap.bytesPerRow * bitmap.height
        )
    }
}

/// A picture fetched by URL, in a box whose height is known in advance.
///
/// The ratio is fixed before anything is downloaded, so the row never grows
/// when the image lands. Every state - loading, loaded, failed - occupies the
/// same space.
///
/// Square-cornered on purpose: whatever places it decides its shape, so a
/// bubble can clip it to its own corners without two roundings fighting.
///
/// ## Fetched with `URLSession.shared`
///
/// Deliberately plain, and worth a decision in a bank: a host that pins
/// certificates pins its own session, and this is not it. If promo artwork has
/// to travel over the pinned session too, this is the one place to change, and
/// the loader becomes something the host injects.
struct RemoteImage: View {
    private let url: URL?
    private let aspectRatio: Double
    @State private var image: UIImage?

    init(url: URL?, aspectRatio: Double) {
        self.url = url
        self.aspectRatio = aspectRatio
        // Read the cache here rather than in `onAppear`: a cached image has to
        // be on screen in the first pass, or a reused cell draws a placeholder
        // frame first and the picture blinks.
        _image = State(initialValue: ImageCache.shared.image(for: url))
    }

    var body: some View {
        Color.clear
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay(content)
            .clipped()
            .task(id: url) { await load() }
    }

    @ViewBuilder
    private var content: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            ImagePlaceholder()
        }
    }

    @MainActor
    private func load() async {
        image = ImageCache.shared.image(for: url)
        guard image == nil, let url else { return }
        let loaded = await ImageLoader.image(from: url)
        guard !Task.isCancelled else { return }
        image = loaded
    }
}

/// What fills the reserved space until the picture arrives, and stays there if
/// it never does.
private struct ImagePlaceholder: View {
    @Environment(\.theme) private var theme

    var body: some View {
        Rectangle()
            .fill(Color(theme.colors.surface))
    }
}
