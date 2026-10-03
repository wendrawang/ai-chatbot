import SwiftUI

public struct SecureCodeIndicator: View {
    @Environment(\.artwork) private var artwork
    let enteredDigitCount: Int
    let totalDigitCount: Int
    let label: String

    public init(enteredDigitCount: Int, totalDigitCount: Int, label: String) {
        self.enteredDigitCount = enteredDigitCount
        self.totalDigitCount = max(0, totalDigitCount)
        self.label = label
    }
    @Environment(\.theme) private var theme

    public var body: some View {
        HStack(spacing: artwork.size(DesignKitMetrics.Spacing.card)) {
            ForEach(0..<totalDigitCount, id: \.self) { index in
                Circle()
                    .fill(indicatorColor(at: index))
                    .frame(width: artwork.size(DesignKitMetrics.Size.secureDigit),
                           height: artwork.size(DesignKitMetrics.Size.secureDigit))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, artwork.size(DesignKitMetrics.Spacing.compact))
        .accessibilityElement(children: .ignore)
        .accessibility(
            label: Text(label)
        )
        .accessibilityIdentifier("secureCode.indicator")
    }

    private func indicatorColor(at index: Int) -> Color {
        Color(
            index < enteredDigitCount
                ? theme.colors.accent
                : theme.colors.chartTrack
        )
    }
}
