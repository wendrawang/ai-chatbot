import SwiftUI

public struct ActivityStatus: View {
    @Environment(\.theme)
    private var theme
    private let text: String
    private let symbolName: String

    public init(text: String, symbolName: String = "sparkles") {
        self.text = text
        self.symbolName = symbolName
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: FigmaSize.spacing8.sizeInArtwork) {
            // TODO: Replace the placeholder symbol with the approved processing emblem from Figma.
            Image(systemName: symbolName)
                .foregroundColor(Color(theme.colors.accent))
                .accessibilityHidden(true)
            Text(text)
                .foregroundColor(Color(theme.colors.secondaryText))
                .fixedSize(horizontal: false, vertical: true)
        }
        .designFont(.caption)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("activity.status")
    }
}
