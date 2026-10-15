import SwiftUI

/// A display card. The caller supplies the image, loading state, or placeholder;
/// this component owns no networking, resource lookup, or navigation.
public struct MediaCard<Media: View>: View {
    @Environment(\.theme)
    private var theme
    private let title: String
    private let subtitle: String?
    private let aspectRatio: CGFloat
    private let media: Media

    public init(
        title: String, subtitle: String? = nil,
        aspectRatio: CGFloat = DesignKitMetrics.Media.aspectRatio,
        @ViewBuilder media: () -> Media
    ) {
        self.title = title
        self.subtitle = subtitle
        self.aspectRatio = aspectRatio.isFinite && aspectRatio > 0 ? aspectRatio : DesignKitMetrics.Media.aspectRatio
        self.media = media()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color.clear
                .aspectRatio(aspectRatio, contentMode: .fit)
                .overlay(media)
                .clipped()
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: FigmaSize.spacing4.sizeInArtwork) {
                Text(title)
                    .designFont(.button)
                    .foregroundColor(Color(theme.colors.primaryText))
                if let subtitle {
                    Text(subtitle)
                        .designFont(.caption)
                        .foregroundColor(Color(theme.colors.secondaryText))
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(FigmaSize.spacing16.sizeInArtwork)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(theme.colors.surface))
        .clipShape(RoundedRectangle(cornerRadius: DesignKitMetrics.Radius.media.sizeInArtwork))
        .accessibilityElement(children: .combine)
    }
}
