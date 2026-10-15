import SwiftUI

/// Horizontal suggestions composed from caller-supplied controls.
/// The caller keeps item identifiers, selection rules, and actions.
public struct SuggestionList<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: FigmaSize.spacing8.scaledToArtwork) {
                content
            }
            .padding(.vertical, FigmaSize.spacing4.scaledToArtwork)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
    }
}
