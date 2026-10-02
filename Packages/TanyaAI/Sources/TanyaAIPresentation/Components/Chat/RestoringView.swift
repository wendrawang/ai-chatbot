import DesignKit
import TanyaAIDomain
import Foundation
import SwiftUI

/// The conversation is being read back from the channel.
///
/// Covers the message list rather than replacing it. The list stays mounted
/// underneath at its real size, so when this goes away the restored
/// conversation is drawn in one piece, already at its latest message - a list
/// swapped in afterwards would start from a zero frame instead.
public struct RestoringView: View {
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

    public init() {}

    public var body: some View {
        VStack(spacing: artwork.size(DesignKitMetrics.Spacing.regular)) {
            ProgressView()
            Text(ChatCopy.text("Loading your conversation"))
                .designFont(.footnote)
                .foregroundColor(Color(theme.colors.secondaryText))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(theme.colors.background))
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(ChatCopy.text("Loading your conversation")))
        .accessibility(identifier: "chat.restoring")
    }
}
