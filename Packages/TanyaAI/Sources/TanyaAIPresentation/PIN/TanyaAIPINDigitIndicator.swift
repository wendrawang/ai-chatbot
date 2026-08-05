import SwiftUI

struct TanyaAIPINDigitIndicator: View {
    let enteredDigitCount: Int
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        HStack(spacing: 18) {
            ForEach(0..<6) { index in
                Circle()
                    .fill(indicatorColor(at: index))
                    .frame(width: 14, height: 14)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibility(
            label: Text("\(enteredDigitCount) of 6 PIN digits entered")
        )
        .tanyaAIAccessibilityIdentifier("pin.indicator")
    }

    private func indicatorColor(at index: Int) -> Color {
        index < enteredDigitCount
            ? theme.colors.accent
            : theme.colors.chartTrack
    }
}
