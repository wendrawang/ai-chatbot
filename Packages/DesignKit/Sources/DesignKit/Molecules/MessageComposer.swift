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

    public var body: some View {
        inputSurface
            .padding(.horizontal, FigmaSize.spacing16.sizeInArtwork)
            .padding(.vertical, FigmaSize.spacing8.sizeInArtwork)
    }

    private var inputSurface: some View {
        HStack(alignment: .bottom, spacing: FigmaSize.spacing8.sizeInArtwork) {
            field
            actionButton
        }
        .padding(.horizontal, FigmaSize.spacing16.sizeInArtwork)
        .padding(.vertical, FigmaSize.spacing8.sizeInArtwork)
        .background(surface)
    }

    private var surface: some View {
        RoundedRectangle(cornerRadius: DesignKitMetrics.Radius.composer.sizeInArtwork)
            .fill(Color.white)
            .shadow(
                color: Color.black.opacity(DesignKitMetrics.Shadow.composerOpacity),
                radius: DesignKitMetrics.Shadow.composerRadius.sizeInArtwork,
                y: DesignKitMetrics.Shadow.composerOffset.sizeInArtwork
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignKitMetrics.Radius.composer.sizeInArtwork)
                    .strokeBorder(
                        Color(theme.colors.divider),
                        lineWidth: DesignKitMetrics.Stroke.hairline.strokeInArtwork
                    )
            )
    }

    private var field: some View {
        ZStack(alignment: .topLeading) {
            GrowingTextInput(
                text: $text,
                font: theme.fonts.body,
                textColor: theme.colors.primaryText.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)),
                accessibilityLabel: placeholder
            )
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)

            if text.isEmpty {
                Text(placeholder)
                    .font(Font(theme.fonts.body))
                    .foregroundColor(Color(theme.colors.secondaryText.resolvedColor(
                        with: UITraitCollection(userInterfaceStyle: .light)
                    )))
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
            }
        }
        .padding(.vertical, FigmaSize.spacing8.sizeInArtwork)
    }

    private var actionButton: some View {
        let isActive = isGenerating || isSendEnabled
        return Button(action: isGenerating ? onStop : onSend) {
            Image(systemName: isGenerating ? "stop.fill" : "arrow.up")
                .designFont(.button)
                .foregroundColor(Color(theme.colors.userBubbleText))
                .frame(
                    width: DesignKitMetrics.Size.composerAction.sizeInArtwork,
                    height: DesignKitMetrics.Size.composerAction.sizeInArtwork
                )
                .background(
                    Circle().fill(Color(isActive ? theme.colors.accent : theme.colors.secondaryText))
                )
                .frame(
                    width: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork,
                    height: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isActive)
        .accessibilityLabel(isGenerating ? stopLabel : sendLabel)
    }

    private var isSendEnabled: Bool {
        isEnabled && text.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty == false
    }
}
