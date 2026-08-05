import SwiftUI

struct TanyaAIPINKeypadView: View {
    let onDigit: (Int) -> Void
    let onDelete: () -> Void
    let isDisabled: Bool
    @Environment(\.tanyaAITheme) private var theme

    private let digitRows = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(digitRows.indices, id: \.self) { index in
                digitRow(digitRows[index])
            }
            finalRow
        }
        .disabled(isDisabled)
    }

    private func digitRow(_ digits: [Int]) -> some View {
        HStack(spacing: 12) {
            ForEach(digits, id: \.self) { digit in
                digitButton(digit)
            }
        }
    }

    private var finalRow: some View {
        HStack(spacing: 12) {
            keypadSpacer
            digitButton(0)
            deleteButton
        }
    }

    private func digitButton(_ digit: Int) -> some View {
        Button(action: { onDigit(digit) }) {
            Text(String(digit))
                .font(theme.fonts.title)
                .foregroundColor(theme.colors.primaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(theme.colors.surface)
                .cornerRadius(14)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibility(label: Text("Digit \(digit)"))
        .tanyaAIAccessibilityIdentifier("pin.digit.\(digit)")
    }

    private var deleteButton: some View {
        Button(action: onDelete) {
            Image(systemName: "delete.left")
                .font(theme.fonts.headline)
                .foregroundColor(theme.colors.secondaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibility(label: Text("Delete PIN digit"))
        .tanyaAIAccessibilityIdentifier("pin.delete")
    }

    private var keypadSpacer: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .accessibility(hidden: true)
    }
}
