import SwiftUI

public struct ItemHeader: View {
    @Environment(\.theme)
    private var theme
    private let title: String
    private let subtitle: String?
    private let detail: String?
    private let symbolName: String?

    public init(title: String, subtitle: String? = nil, detail: String? = nil, symbolName: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.detail = detail
        self.symbolName = symbolName
    }

    public var body: some View {
        HStack(alignment: .top, spacing: FigmaSize.spacing8.sizeInArtwork) {
            if let symbolName = symbolName {
                Image(systemName: symbolName)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: DesignKitMetrics.Size.icon.sizeInArtwork,
                        height: DesignKitMetrics.Size.icon.sizeInArtwork
                    )
                    .foregroundColor(Color(theme.colors.userBubbleText))
                    .frame(
                        width: DesignKitMetrics.Conversation.itemIcon.sizeInArtwork,
                        height: DesignKitMetrics.Conversation.itemIcon.sizeInArtwork
                    )
                    .background(Color(theme.colors.accent))
                    .clipShape(Circle())
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: FigmaSize.spacing4.sizeInArtwork) {
                Text(title)
                    .designFont(.button)
                    .foregroundColor(Color(theme.colors.primaryText))
                if let subtitle = subtitle {
                    Text(subtitle).designFont(.caption).foregroundColor(Color(theme.colors.secondaryText))
                }
                if let detail = detail {
                    Text(detail).designFont(.caption).foregroundColor(Color(theme.colors.secondaryText))
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
