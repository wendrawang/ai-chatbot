//
//  MessageComposer.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import SwiftUI

/// Inner spacing and appearance belong here; the screen owns outer margins.
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
    private let isEnabled: Bool
    private let fontFace: FontFace
    private let onSend: () -> Void

    public init(
        text: Binding<String>, placeholder: String, sendLabel: String,
        isEnabled: Bool = true, fontFace: FontFace = .openSansRegular, onSend: @escaping () -> Void
    ) {
        self._text = text
        self.placeholder = placeholder
        self.sendLabel = sendLabel
        self.isEnabled = isEnabled
        self.fontFace = fontFace
        self.onSend = onSend
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
        .accessibilityIdentifier(ComponentIdentifier.composer)
    }

    private var field: some View {
        ZStack(alignment: .leading) {
            GrowingTextInput(
                text: $text, font: inputFont, textColor: UIColor(colors.colorsTextPrimaryDark),
                lineSpacing: lineSpacing, accessibilityLabel: placeholder
            )
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .accessibilityIdentifier(ComponentIdentifier.input)
            if text.isEmpty {
                Text(placeholder)
                    .font(Font(inputFont))
                    .lineLimit(CustomSizes.InputText.minimumLines)
                    .foregroundColor(colors.colorsTextSecondary)
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
            }
        }
    }

    private var actionButton: some View {
        Button(action: onSend) {
            Image(R.image.sendArrow).resizable().scaledToFit()
                .padding(CustomSizes.ActionButton.iconInset.scaledToArtwork)
                .foregroundColor(colors.colorsIconLight)
                .frame(
                    width: CustomSizes.ActionButton.visualSize.scaledToArtwork,
                    height: CustomSizes.ActionButton.visualSize.scaledToArtwork
                )
                .background(Circle().fill(isSendEnabled ? colors.colorsButtonActive : colors.colorsIconDisabled))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isSendEnabled)
        .accessibilityLabel(sendLabel)
        .accessibilityIdentifier(ComponentIdentifier.send)
    }

    private var surface: some View {
        RoundedRectangle(cornerRadius: CustomSizes.Radius.composer.scaledToArtwork)
            .fill(colors.colorsSurfacePrimary)
            .shadow(
                color: CustomColors.Shadow.color, radius: CustomSizes.Shadow.radius.scaledToArtwork,
                y: CustomSizes.Shadow.offsetY.scaledToArtwork
            )
            .overlay(
                RoundedRectangle(cornerRadius: CustomSizes.Radius.composer.scaledToArtwork)
                    .strokeBorder(CustomColors.Stroke.color, lineWidth: FigmaSize.weightOutline.scaledToArtwork)
            )
    }
}

// MARK: - Helpers

private extension MessageComposer {
    var inputFont: UIFont { fontFace.font(size: fontSize) }

    /// Equal single-line rows center the field/button; a taller field keeps the button at its bottom.
    var singleLineRowHeight: CGFloat {
        max(CustomSizes.ActionButton.visualSize.scaledToArtwork, ceil(inputFont.lineHeight + lineSpacing))
    }

    var lineSpacing: CGFloat {
        let leading = FigmaSize.typographyLineHeightDisplaySmall14.scaledToArtwork
        return max(.zero, leading - inputFont.lineHeight)
    }

    var isSendEnabled: Bool {
        isEnabled && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
