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
    }

    func image(for url: URL?) -> UIImage? {
        guard let url = url else {
            return nil
        }
        return storage.object(forKey: url as NSURL)
    }

    func store(_ image: UIImage, for url: URL) {
        storage.setObject(image, forKey: url as NSURL)
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
            .onAppear(perform: load)
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

    private func load() {
        guard image == nil, let url = url else {
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let loaded = UIImage(data: data) else {
                // Left as the placeholder on purpose. The caption under the
                // picture already carries the message; an error badge here
                // would draw attention to the less important half.
                return
            }
            ImageCache.shared.store(loaded, for: url)
            DispatchQueue.main.async {
                image = loaded
            }
        }.resume()
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
