//
//  MessageComposer.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import SwiftUI

/// Inner spacing and appearance belong here; the screen owns outer margins.
/// `action` mengganti tombol kirim dengan titik bergerak (sedang mengirim) atau stop (menunggu jawaban).
@MainActor
public struct MessageComposer: View {
    @Environment(\.designColors)
    private var colors
    @Binding
    private var text: String
    // Figma typography follows artwork scaling only, independent of the user's text size setting.
    private let fontSize = FigmaSize.typographySizeDisplaySmall14.scaledToArtwork
    private let placeholder: String
    private let sendLabel: String
    private let stopLabel: String
    private let action: ComposerAction
    private let isEnabled: Bool
    private let fontFace: FontFace
    private let onSend: () -> Void
    private let onStop: () -> Void

    public init(
        text: Binding<String>, placeholder: String, sendLabel: String, stopLabel: String,
        action: ComposerAction = .send, isEnabled: Bool = true, fontFace: FontFace = .openSansRegular,
        onSend: @escaping () -> Void, onStop: @escaping () -> Void = {}
    ) {
        self._text = text
        self.placeholder = placeholder
        self.sendLabel = sendLabel
        self.stopLabel = stopLabel
        self.action = action
        self.isEnabled = isEnabled
        self.fontFace = fontFace
        self.onSend = onSend
        self.onStop = onStop
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: FigmaSize.spacingLarge.scaledToArtwork) {
            field
                .frame(minHeight: singleLineRowHeight)
            actionButton
                .frame(minHeight: singleLineRowHeight)
        }
        .padding(FigmaSize.spacingLarge.scaledToArtwork)
        .cardStyle()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(ComponentIdentifier.Composer.root)
    }

    private var field: some View {
        ZStack(alignment: .leading) {
            GrowingTextInput(
                text: $text, font: inputFont, textColor: UIColor(colors.colorsTextPrimaryDark),
                lineSpacing: lineSpacing, accessibilityLabel: placeholder
            )
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .accessibilityIdentifier(ComponentIdentifier.Composer.input)
            if text.isEmpty {
                Text(placeholder)
                    .font(Font(inputFont))
                    .lineLimit(CustomTextLines.composerInput.lowerBound)
                    .foregroundColor(colors.colorsTextSecondary)
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
            }
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        switch action {
        case .send:
            sendButton
        case .sending:
            sendingIndicator
        case .stop:
            stopButton
        }
    }

    private var sendButton: some View {
        Button(action: onSend) {
            Image(DesignIcon.sendArrow).resizable().scaledToFit()
                .padding(CustomSizes.Composer.sendIconInset.scaledToArtwork)
                .foregroundColor(colors.colorsIconLight)
                .frame(width: buttonSize, height: buttonSize)
                .background(Circle().fill(isSendEnabled ? colors.colorsButtonActive : colors.colorsIconDisabled))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isSendEnabled)
        .accessibilityLabel(sendLabel)
        .accessibilityIdentifier(ComponentIdentifier.Composer.send)
    }

    private var sendingIndicator: some View {
        LoadingDots(color: colors.colorsIconLight)
            .frame(width: buttonSize, height: buttonSize)
            .background(Circle().fill(colors.colorsButtonActive))
            .accessibilityElement()
            .accessibilityLabel(sendLabel)
            .accessibilityIdentifier(ComponentIdentifier.Composer.sending)
    }

    private var stopButton: some View {
        Button(action: onStop) {
            RoundedRectangle(cornerRadius: CustomSizes.Composer.stopMarkRadius.scaledToArtwork)
                .fill(colors.colorsIconLight)
                .frame(
                    width: CustomSizes.Composer.stopMark.scaledToArtwork,
                    height: CustomSizes.Composer.stopMark.scaledToArtwork
                )
                .frame(width: buttonSize, height: buttonSize)
                .background(Circle().fill(isEnabled ? colors.colorsButtonActive : colors.colorsIconDisabled))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(stopLabel)
        .accessibilityIdentifier(ComponentIdentifier.Composer.stop)
    }
}

// MARK: - Helpers

private extension MessageComposer {
    var inputFont: UIFont { fontFace.font(size: fontSize) }

    var buttonSize: CGFloat { CustomSizes.Composer.sendButton.scaledToArtwork }

    /// Equal single-line rows center the field/button; a taller field keeps the button at its bottom.
    var singleLineRowHeight: CGFloat {
        max(buttonSize, ceil(inputFont.lineHeight + lineSpacing))
    }

    var lineSpacing: CGFloat {
        let leading = FigmaSize.typographyLineHeightDisplaySmall14.scaledToArtwork
        return max(.zero, leading - inputFont.lineHeight)
    }

    var isSendEnabled: Bool {
        isEnabled && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
