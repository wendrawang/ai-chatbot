import SwiftUI
import UIKit

/// One choice in a `ChoicesBubble`.
///
/// The tick's space is reserved whether or not it is showing. A chip that grew
/// on selection would repack the rows under the customer's finger, and the
/// choice they meant to tap next would have moved.
public struct ChoiceChip: View {
    let choice: ChoicesPayload.Choice
    let isSelected: Bool
    let isEnabled: Bool
    let onTap: () -> Void
    @Environment(\.theme) private var theme

    /// The tick and the gap after it, reserved in every chip.
    static let indicatorWidth: CGFloat = 20

    public init(
        choice: ChoicesPayload.Choice,
        isSelected: Bool,
        isEnabled: Bool,
        onTap: @escaping () -> Void
    ) {
        self.choice = choice
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.onTap = onTap
    }

    /// How wide this chip wants to be, so rows can be packed before anything
    /// is drawn. Measured with the same font the label uses.
    static func width(
        of choice: ChoicesPayload.Choice,
        font: UIFont
    ) -> CGFloat {
        let text = (choice.title as NSString).size(
            withAttributes: [.font: font]
        ).width
        return text
            + indicatorWidth
            + DesignKitMetrics.Spacing.compact
            + DesignKitMetrics.Spacing.wide * 2
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignKitMetrics.Spacing.compact) {
                tick
                Text(choice.title)
                    .font(Font(theme.fonts.body))
                    .lineLimit(1)
            }
            .padding(.horizontal, DesignKitMetrics.Spacing.wide)
            .frame(minHeight: DesignKitMetrics.Size.minimumTapTarget)
        }
        .disabled(isEnabled == false)
        .foregroundColor(Color(foreground))
        .background(background)
        .accessibilityIdentifier("choice.\(choice.identifier)")
        .accessibility(
            label: Text(choice.title)
        )
        .accessibility(addTraits: isSelected ? [.isSelected] : [])
    }

    private var tick: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 12, weight: .bold))
            .frame(width: Self.indicatorWidth)
            .opacity(isSelected ? 1 : 0)
    }

    private var background: some View {
        Capsule()
            .fill(
                isSelected
                    ? Color(theme.colors.accent).opacity(0.1)
                    : Color(theme.colors.assistantBubble)
            )
            .overlay(
                Capsule().stroke(
                    Color(isSelected ? theme.colors.accent : theme.colors.divider),
                    lineWidth: DesignKitMetrics.Stroke.hairline
                )
            )
    }

    private var foreground: UIColor {
        guard isEnabled else {
            return theme.colors.secondaryText
        }
        return isSelected ? theme.colors.accent : theme.colors.primaryText
    }
}
