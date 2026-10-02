import SwiftUI

public struct SummaryRow: View {
    private let title: String
    private let detail: String
    @Environment(\.artwork) private var artwork
    @Environment(\.theme) private var theme

    public init(title: String, detail: String) {
        self.title = title
        self.detail = detail
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: artwork.size(DesignKitMetrics.Spacing.tight)) {
            Text(title)
                .designFont(.headline)
                .foregroundColor(Color(theme.colors.primaryText))
            Text(detail)
                .designFont(.subheadline)
                .foregroundColor(Color(theme.colors.secondaryText))
        }
        .padding(.vertical, artwork.size(DesignKitMetrics.Spacing.tight))
    }
}
