import DesignKit
import SwiftUI

struct DemoHostKeypad: View {
    @Environment(\.theme)
    private var theme
    static let digitSize: CGFloat = 14
    private let keyHeight: CGFloat = 54

    let onDigit: (Int) -> Void
    let onDelete: () -> Void
    let isDisabled: Bool

    init(onDigit: @escaping (Int) -> Void, onDelete: @escaping () -> Void, isDisabled: Bool = false) {
        self.onDigit = onDigit
        self.onDelete = onDelete
        self.isDisabled = isDisabled
    }

    private let digitRows = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

    var body: some View {
        VStack(spacing: FigmaSize.spacing8.scaledToArtwork) {
            ForEach(digitRows.indices, id: \.self) { index in
                digitRow(digitRows[index])
            }
            finalRow
        }
        .disabled(isDisabled)
    }

    private func digitRow(_ digits: [Int]) -> some View {
        HStack(spacing: DesignKitMetrics.Spacing.regular.scaledToArtwork) {
            ForEach(digits, id: \.self) { digit in
                digitButton(digit)
            }
        }
    }

    private var finalRow: some View {
        HStack(spacing: DesignKitMetrics.Spacing.regular.scaledToArtwork) {
            keypadSpacer
            digitButton(0)
            deleteButton
        }
    }

    private func digitButton(_ digit: Int) -> some View {
        Button(
            action: { onDigit(digit) },
            label: {
                Text(String(digit))
                    .designFont(.title)
                    .foregroundColor(Color(theme.colors.primaryText))
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: keyHeight.tapTargetInArtwork)
                    .background(Color(theme.colors.surface))
                    .cornerRadius(FigmaSize.spacing16.scaledToArtwork)
            }
        )
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Digit \(digit)")
        .accessibilityIdentifier("keypad.digit.\(digit)")
    }

    private var deleteButton: some View {
        Button(action: onDelete) {
            Image(systemName: "delete.left")
                .designFont(.headline)
                .foregroundColor(Color(theme.colors.secondaryText))
                .frame(maxWidth: .infinity)
                .frame(minHeight: keyHeight.tapTargetInArtwork)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Hapus digit")
        .accessibilityIdentifier("keypad.delete")
    }

    private var keypadSpacer: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(minHeight: keyHeight.tapTargetInArtwork)
            .accessibility(hidden: true)
    }
}
