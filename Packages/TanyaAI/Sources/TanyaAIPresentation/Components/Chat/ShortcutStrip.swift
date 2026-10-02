import DesignKit
import TanyaAIDomain
import SwiftUI

/// The shortcuts a host offers above the keyboard.
///
/// Not the same thing as the prompts a reply offers, despite looking alike.
/// These come from the application, not the bot; they answer no question in
/// particular; and they stay put after one is used, because they are a way in
/// rather than a reply to something just said.
public struct ShortcutStrip: View {
    let shortcuts: [Suggestion]
    let onSelect: (Suggestion) -> Void
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

    public init(
        shortcuts: [Suggestion],
        onSelect: @escaping (Suggestion) -> Void
    ) {
        self.shortcuts = shortcuts
        self.onSelect = onSelect
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: artwork.size(DesignKitMetrics.Spacing.compact)) {
                ForEach(shortcuts, id: \.identifier) { shortcut in
                    Button(
                        action: { onSelect(shortcut) },
                        label: { label(shortcut) }
                    )
                    .foregroundColor(Color(theme.colors.accent))
                    .background(pill)
                    .accessibilityIdentifier("shortcut.\(shortcut.identifier)")
                    .accessibility(
                        label: Text(String(format: ChatCopy.text("Shortcut: %@"), shortcut.title))
                    )
                }
            }
            .padding(.horizontal, artwork.size(DesignKitMetrics.Spacing.regular))
            .padding(.vertical, artwork.size(DesignKitMetrics.Spacing.compact))
        }
        .accessibilityIdentifier("shortcuts.strip")
    }

    private func label(_ shortcut: Suggestion) -> some View {
        Text(shortcut.title)
            .designFont(.button)
            .lineLimit(1)
            .padding(.horizontal, artwork.size(DesignKitMetrics.Spacing.wide))
            .frame(minHeight: artwork.tapTarget(DesignKitMetrics.Size.minimumTapTarget))
    }

    private var pill: some View {
        Capsule()
            .fill(Color(theme.colors.assistantBubble))
            .overlay(
                Capsule().stroke(
                    Color(theme.colors.divider),
                    lineWidth: artwork.stroke(DesignKitMetrics.Stroke.hairline)
                )
            )
    }
}
