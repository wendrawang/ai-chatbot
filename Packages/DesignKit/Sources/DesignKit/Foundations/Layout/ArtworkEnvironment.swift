import SwiftUI

private struct ArtworkKey: EnvironmentKey {
    static let defaultValue = ArtworkMetrics()
}

public extension EnvironmentValues {
    var artwork: ArtworkMetrics {
        get { self[ArtworkKey.self] }
        set { self[ArtworkKey.self] = newValue }
    }
}

private struct ArtworkLayout: ViewModifier {
    let referenceSize: CGSize
    let maximumScale: CGFloat
    @Environment(\.displayScale) private var displayScale

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .environment(\.artwork, ArtworkMetrics(
                    containerSize: geometry.size,
                    referenceSize: referenceSize,
                    displayScale: displayScale,
                    maximumScale: maximumScale
                ))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

public extension View {
    /// Apply once to a screen/container root, outside `.theme(...)`.
    func artworkLayout(
        referenceSize: CGSize = ArtworkMetrics.referenceSize,
        maximumScale: CGFloat = DesignKitMetrics.Artwork.maximumScale
    ) -> some View {
        modifier(ArtworkLayout(referenceSize: referenceSize, maximumScale: maximumScale))
    }

    /// UIKit hosts and previews can supply already measured container metrics.
    func artwork(_ metrics: ArtworkMetrics) -> some View {
        environment(\.artwork, metrics)
    }
}
