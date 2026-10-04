import SwiftUI

public struct SummaryRow: View {
    private let title: String
    private let detail: String

    @Environment(\.theme) private var theme

    public init(title: String, detail: String) {
        self.title = title
        self.detail = detail
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignKitMetrics.Spacing.tight.sizeInArtwork) {
            Text(title)
                .designFont(.headline)
                .foregroundColor(Color(theme.colors.primaryText))
            Text(detail)
                .designFont(.subheadline)
                .foregroundColor(Color(theme.colors.secondaryText))
        }
        .padding(.vertical, DesignKitMetrics.Spacing.tight.sizeInArtwork)
    }
}
