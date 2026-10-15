import SwiftUI

/// A chronological separator. The caller supplies the already formatted date.
public struct DateSeparator: View {
    @Environment(\.theme)
    private var theme
    private let text: String

    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .designFont(.caption)
            .foregroundColor(Color(theme.colors.secondaryText))
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, FigmaSize.spacing8.scaledToArtwork)
    }
}
