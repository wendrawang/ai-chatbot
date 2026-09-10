import Foundation
import SwiftUI

/// The conversation is being read back from the channel.
///
/// Covers the message list rather than replacing it. The list stays mounted
/// underneath at its real size, so when this goes away the restored
/// conversation is drawn in one piece, already at its latest message - a list
/// swapped in afterwards would start from a zero frame instead.
struct TanyaAIRestoringView: View {
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading your conversation")
                .font(Font(theme.fonts.footnote))
                .foregroundColor(Color(theme.colors.secondaryText))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(theme.colors.background))
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("Loading your conversation"))
        .accessibility(identifier: "chat.restoring")
    }
}
