//
//  MessageComposer.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import SwiftUI

/// Inner spacing and appearance belong here; the screen owns outer margins.
/// Saat jawaban sedang mengalir (`isResponding`), tombol kirim berganti menjadi stop.
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
    private let isResponding: Bool
    private let fontFace: FontFace
    private let onSend: () -> Void
    private let onStop: () -> Void

    public init(
        text: Binding<String>, placeholder: String, sendLabel: String, stopLabel: String,
        isResponding: Bool = false, fontFace: FontFace = .firaSansRegular,
        onSend: @escaping () -> Void, onStop: @escaping () -> Void = {}
    ) {
        self._text = text
        self.placeholder = placeholder
        self.sendLabel = sendLabel
        self.stopLabel = stopLabel
        self.isResponding = isResponding
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
        .background(surface)
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
        if isResponding { stopButton } else { sendButton }
    }

    private var sendButton: some View {
        Button(action: onSend) {
            Image(R.image.sendArrow).resizable().scaledToFit()
                .padding(CustomSizes.Composer.sendIconInset.scaledToArtwork)
                .foregroundColor(colors.colorsIconLight)
                .frame(
                    width: CustomSizes.Composer.sendButton.scaledToArtwork,
                    height: CustomSizes.Composer.sendButton.scaledToArtwork
                )
                .background(Circle().fill(isSendEnabled ? colors.colorsButtonActive : colors.colorsIconDisabled))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isSendEnabled)
        .accessibilityLabel(sendLabel)
        .accessibilityIdentifier(ComponentIdentifier.Composer.send)
    }

    private var stopButton: some View {
        Button(action: onStop) {
            RoundedRectangle(cornerRadius: CustomSizes.Composer.stopMarkRadius.scaledToArtwork)
                .fill(colors.colorsIconLight)
                .frame(
                    width: CustomSizes.Composer.stopMark.scaledToArtwork,
                    height: CustomSizes.Composer.stopMark.scaledToArtwork
                )
                .frame(
                    width: CustomSizes.Composer.sendButton.scaledToArtwork,
                    height: CustomSizes.Composer.sendButton.scaledToArtwork
                )
                .background(Circle().fill(colors.colorsButtonActive))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(stopLabel)
        .accessibilityIdentifier(ComponentIdentifier.Composer.stop)
    }

    private var surface: some View {
        RoundedRectangle(cornerRadius: CustomSizes.Composer.cornerRadius.scaledToArtwork)
            .fill(colors.colorsSurfacePrimary)
            .shadow(
                color: CustomColors.Shadow.color, radius: CustomSizes.Shadow.radius.scaledToArtwork,
                y: CustomSizes.Shadow.offsetY.scaledToArtwork
            )
            .overlay(
                RoundedRectangle(cornerRadius: CustomSizes.Composer.cornerRadius.scaledToArtwork)
                    .strokeBorder(CustomColors.Stroke.color, lineWidth: FigmaSize.weightOutline.scaledToArtwork)
            )
    }
}

// MARK: - Helpers

private extension MessageComposer {
    var inputFont: UIFont { fontFace.font(size: fontSize) }

    /// Equal single-line rows center the field/button; a taller field keeps the button at its bottom.
    var singleLineRowHeight: CGFloat {
        max(CustomSizes.Composer.sendButton.scaledToArtwork, ceil(inputFont.lineHeight + lineSpacing))
    }

    var lineSpacing: CGFloat {
        let leading = FigmaSize.typographyLineHeightDisplaySmall14.scaledToArtwork
        return max(.zero, leading - inputFont.lineHeight)
    }

    var isSendEnabled: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
