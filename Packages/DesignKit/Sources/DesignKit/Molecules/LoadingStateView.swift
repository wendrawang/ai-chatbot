import Foundation
import SwiftUI

/// The conversation is being read back from the channel.
///
/// Covers the message list rather than replacing it. The list stays mounted
/// underneath at its real size, so when this goes away the restored
/// conversation is drawn in one piece, already at its latest message - a list
/// swapped in afterwards would start from a zero frame instead.
public struct LoadingStateView: View {
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

    private let label: String

    public init(label: String) {
        self.label = label
    }

    public var body: some View {
        VStack(spacing: artwork.size(DesignKitMetrics.Spacing.regular)) {
            ProgressView()
            Text(label)
                .designFont(.footnote)
                .foregroundColor(Color(theme.colors.secondaryText))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(theme.colors.background))
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(label))
        .accessibility(identifier: "chat.restoring")
    }
}
