import SwiftUI

/// The composer.
///
/// A single capsule holds the field, and the action sits in a filled circle
/// beside it: sending and stopping occupy the same place, so the control the
/// customer reaches for never moves.
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
        HStack(alignment: .bottom, spacing: artwork.size(DesignKitMetrics.Spacing.medium)) {
            field
            actionButton
        }
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
        .padding(.horizontal, artwork.size(DesignKitMetrics.Spacing.card))
        .padding(.vertical, artwork.size(DesignKitMetrics.Spacing.regular))
        .background(Color(theme.colors.surface))
        .clipShape(RoundedRectangle(cornerRadius: artwork.size(DesignKitMetrics.Radius.composer)))
        .overlay(
            RoundedRectangle(cornerRadius: artwork.size(DesignKitMetrics.Radius.composer))
                .stroke(Color(theme.colors.divider), lineWidth: artwork.stroke(DesignKitMetrics.Stroke.hairline))
        )
    }

    @ViewBuilder
    private var actionButton: some View {
        if isGenerating {
            circularButton(
                symbol: "stop.fill",
                label: stopLabel,
                action: onStop
            )
        } else {
            circularButton(
                symbol: "arrow.up",
                label: sendLabel,
                action: onSend
            )
            .opacity(isSendEnabled ? 1 : DesignKitMetrics.Opacity.disabledSend)
            .disabled(isSendEnabled == false)
        }
    }

    private func circularButton(
        symbol: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .designFont(.button)
                .foregroundColor(Color(theme.colors.userBubbleText))
                .frame(width: artwork.tapTarget(), height: artwork.tapTarget())
                .background(Color(theme.colors.accent))
                .clipShape(Circle())
        }
        .accessibility(label: Text(label))
    }

    private var isSendEnabled: Bool {
        isEnabled && text.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty == false
    }
}
