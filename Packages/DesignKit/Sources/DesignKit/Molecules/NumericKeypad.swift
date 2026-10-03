import SwiftUI

public struct NumericKeypad: View {
    @Environment(\.artwork) private var artwork
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
        VStack(spacing: artwork.size(DesignKitMetrics.Spacing.medium)) {
            ForEach(digitRows.indices, id: \.self) { index in
                digitRow(digitRows[index])
            }
            finalRow
        }
        .disabled(isDisabled)
    }

    private func digitRow(_ digits: [Int]) -> some View {
        HStack(spacing: artwork.size(DesignKitMetrics.Spacing.regular)) {
            ForEach(digits, id: \.self) { digit in
                digitButton(digit)
            }
        }
    }

    private var finalRow: some View {
        HStack(spacing: artwork.size(DesignKitMetrics.Spacing.regular)) {
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
                    .frame(minHeight: artwork.tapTarget(DesignKitMetrics.Size.keypadHeight))
                    .background(Color(theme.colors.surface))
                    .cornerRadius(artwork.size(DesignKitMetrics.Radius.keypad))
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
                .frame(minHeight: artwork.tapTarget(DesignKitMetrics.Size.keypadHeight))
        }
        .buttonStyle(PlainButtonStyle())
        .accessibility(label: Text(copy.design("design.deleteDigit")))
        .accessibilityIdentifier("keypad.delete")
    }

    private var keypadSpacer: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(minHeight: artwork.tapTarget(DesignKitMetrics.Size.keypadHeight))
            .accessibility(hidden: true)
    }
}
