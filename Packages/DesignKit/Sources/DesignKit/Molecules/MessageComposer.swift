import SwiftUI

/// The composer.
///
/// A rounded container holds both the growing field and its trailing action.
/// The action stays at the bottom as the field grows to four lines.
public struct MessageComposer: View {
    @Binding private var text: String
    private let placeholder: String
    private let sendLabel: String
    private let stopLabel: String
    private let isGenerating: Bool
    private let isEnabled: Bool
    private let onSend: () -> Void
    private let onStop: () -> Void

    public init(
        text: Binding<String>, placeholder: String, sendLabel: String, stopLabel: String,
        isGenerating: Bool, isEnabled: Bool = true,
        onSend: @escaping () -> Void, onStop: @escaping () -> Void
    ) {
        self._text = text
        self.placeholder = placeholder
        self.sendLabel = sendLabel
        self.stopLabel = stopLabel
        self.isGenerating = isGenerating
        self.isEnabled = isEnabled
        self.onSend = onSend
        self.onStop = onStop
    }
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

    public var body: some View {
        HStack(alignment: .bottom, spacing: artwork.size(DesignKitMetrics.Spacing.compact)) {
            field
            actionButton
        }
        .padding(.horizontal, artwork.size(DesignKitMetrics.Spacing.wide))
        .padding(.vertical, artwork.size(DesignKitMetrics.Spacing.compact))
        .background(Color(theme.colors.surface))
        .clipShape(RoundedRectangle(cornerRadius: artwork.size(DesignKitMetrics.Radius.composer)))
        .overlay(
            RoundedRectangle(cornerRadius: artwork.size(DesignKitMetrics.Radius.composer))
                .stroke(Color(theme.colors.divider), lineWidth: artwork.stroke(DesignKitMetrics.Stroke.hairline))
        )
        .padding(.horizontal, artwork.size(DesignKitMetrics.Spacing.wide))
        .padding(.vertical, artwork.size(DesignKitMetrics.Spacing.regular))
        .background(Color(theme.colors.background))
    }

    private var field: some View {
        ZStack(alignment: .topLeading) {
            GrowingTextInput(
                text: $text,
                font: theme.fonts.body,
                textColor: theme.colors.primaryText,
                accessibilityLabel: placeholder
            )
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)

            if text.isEmpty {
                Text(placeholder)
                    .font(Font(theme.fonts.body))
                    .foregroundColor(Color(theme.colors.secondaryText))
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
            }
        }
        .padding(.vertical, artwork.size(DesignKitMetrics.Spacing.compact))
    }

    @ViewBuilder
    private var actionButton: some View {
        if isGenerating {
            circularButton(
                symbol: "stop.fill",
                label: stopLabel,
                isActive: true, action: onStop
            )
        } else {
            circularButton(
                symbol: "arrow.up",
                label: sendLabel,
                isActive: isSendEnabled, action: onSend
            )
            .disabled(isSendEnabled == false)
        }
    }

    private func circularButton(
        symbol: String,
        label: String,
        isActive: Bool, action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .designFont(.button)
                .foregroundColor(Color(theme.colors.userBubbleText))
                .frame(
                    width: artwork.size(DesignKitMetrics.Size.composerAction),
                    height: artwork.size(DesignKitMetrics.Size.composerAction)
                )
                .background(Color(isActive ? theme.colors.accent : theme.colors.secondaryText))
                .clipShape(Circle())
                .frame(width: artwork.tapTarget(), height: artwork.tapTarget())
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibility(label: Text(label))
    }

    private var isSendEnabled: Bool {
        isEnabled && text.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty == false
    }
}
