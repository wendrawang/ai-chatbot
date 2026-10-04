import SwiftUI

public struct SecureCodeIndicator: View {

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
        HStack(spacing: DesignKitMetrics.Spacing.card.sizeInArtwork) {
            ForEach(0..<totalDigitCount, id: \.self) { index in
                Circle()
                    .fill(indicatorColor(at: index))
                    .frame(width: DesignKitMetrics.Size.secureDigit.sizeInArtwork,
                           height: DesignKitMetrics.Size.secureDigit.sizeInArtwork)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignKitMetrics.Spacing.compact.sizeInArtwork)
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
