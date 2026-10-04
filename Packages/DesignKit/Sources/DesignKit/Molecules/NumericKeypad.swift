import SwiftUI

public struct NumericKeypad: View {

    let onDigit: (Int) -> Void
    let onDelete: () -> Void
    let isDisabled: Bool
    @Environment(\.theme) private var theme

    @Environment(\.copyCatalog) private var copy

    public init(onDigit: @escaping (Int) -> Void, onDelete: @escaping () -> Void, isDisabled: Bool = false) {
        self.onDigit = onDigit
        self.onDelete = onDelete
        self.isDisabled = isDisabled
    }

    private let digitRows = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

    public var body: some View {
        VStack(spacing: DesignKitMetrics.Spacing.medium.sizeInArtwork) {
            ForEach(digitRows.indices, id: \.self) { index in
                digitRow(digitRows[index])
            }
            finalRow
        }
        .disabled(isDisabled)
    }

    private func digitRow(_ digits: [Int]) -> some View {
        HStack(spacing: DesignKitMetrics.Spacing.regular.sizeInArtwork) {
            ForEach(digits, id: \.self) { digit in
                digitButton(digit)
            }
        }
    }

    private var finalRow: some View {
        HStack(spacing: DesignKitMetrics.Spacing.regular.sizeInArtwork) {
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
                    .font(Font(theme.fonts.title))
                    .foregroundColor(Color(theme.colors.primaryText))
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: DesignKitMetrics.Size.keypadHeight.tapTargetInArtwork)
                    .background(Color(theme.colors.surface))
                    .cornerRadius(DesignKitMetrics.Radius.keypad.sizeInArtwork)
            }
        )
        .buttonStyle(PlainButtonStyle())
        .accessibility(label: Text(copy.design("design.digit", values: ["digit": String(digit)])))
        .accessibilityIdentifier("keypad.digit.\(digit)")
    }

    private var deleteButton: some View {
        Button(action: onDelete) {
            Image(systemName: "delete.left")
                .font(Font(theme.fonts.headline))
                .foregroundColor(Color(theme.colors.secondaryText))
                .frame(maxWidth: .infinity)
                .frame(minHeight: DesignKitMetrics.Size.keypadHeight.tapTargetInArtwork)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibility(label: Text(copy.design("design.deleteDigit")))
        .accessibilityIdentifier("keypad.delete")
    }

    private var keypadSpacer: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(minHeight: DesignKitMetrics.Size.keypadHeight.tapTargetInArtwork)
            .accessibility(hidden: true)
    }
}
