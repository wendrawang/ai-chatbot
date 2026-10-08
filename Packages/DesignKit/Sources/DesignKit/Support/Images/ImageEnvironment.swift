import SwiftUI

private struct ImageLoaderKey: EnvironmentKey {
    static let defaultValue: ImageLoading = ImageLoader.shared
}

public extension EnvironmentValues {
    var imageLoader: ImageLoading {
        get { self[ImageLoaderKey.self] }
        set { self[ImageLoaderKey.self] = newValue }
    }
}

public extension View {
    func imageLoader(_ loader: ImageLoading) -> some View {
        environment(\.imageLoader, loader)
    }
}
