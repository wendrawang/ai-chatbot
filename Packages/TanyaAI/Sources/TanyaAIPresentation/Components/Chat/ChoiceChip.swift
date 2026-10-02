import DesignKit
import TanyaAIDomain
import SwiftUI
import UIKit

/// One choice in a `ChoicesBubble`.
///
/// The tick appears only when selected, so a chip is as wide as its words.
/// Reserving the tick's width in every chip was tried first, to stop rows
/// repacking under the customer's finger - but 20pt per chip was enough to
/// keep any two from sharing a row, which turned a flowing grid into a single
/// column and lost the shape the design is built on. Repacking is the smaller
/// cost of the two.
public struct ChoiceChip: View {
    let choice: ChoicesPayload.Choice
    let isSelected: Bool
    let isEnabled: Bool
    let onTap: () -> Void
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

    /// The tick and the gap after it, counted only when it is showing.
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
    /// is drawn. Measured with the same font the label uses, and with the tick
    /// counted only when this chip is showing one.
    static func width(
        of choice: ChoicesPayload.Choice,
        isSelected: Bool,
        font: UIFont,
        artwork: ArtworkMetrics = ArtworkMetrics()
    ) -> CGFloat {
        let text = (choice.title as NSString).size(
            withAttributes: [.font: font]
        ).width
        let tick = isSelected
            ? artwork.size(indicatorWidth) + artwork.size(DesignKitMetrics.Spacing.compact)
            : 0
        return ceil(text) + tick + artwork.size(DesignKitMetrics.Spacing.wide) * 2
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: artwork.size(DesignKitMetrics.Spacing.compact)) {
                if isSelected {
                    tick
                }
                Text(choice.title)
                    .designFont(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, artwork.size(DesignKitMetrics.Spacing.wide))
            .frame(minHeight: artwork.tapTarget(DesignKitMetrics.Size.minimumTapTarget))
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
            .font(.system(size: artwork.size(DesignKitMetrics.Spacing.regular), weight: .bold))
            .frame(width: artwork.size(Self.indicatorWidth))
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
                    lineWidth: artwork.stroke(DesignKitMetrics.Stroke.hairline)
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
