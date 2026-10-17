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
    private let placeholder: String
    private let sendLabel: String
    private let isEnabled: Bool
    private let textStyle: DesignTextStyle
    private let onSend: () -> Void

    public init(
        text: Binding<String>, placeholder: String, sendLabel: String,
        isEnabled: Bool = true, textStyle: DesignTextStyle = .body, onSend: @escaping () -> Void
    ) {
        self._text = text
        self.placeholder = placeholder
        self.sendLabel = sendLabel
        self.isEnabled = isEnabled
        self.textStyle = textStyle
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
        .accessibilityIdentifier(ComponentIdentifier.Composer.root)
    }

    private var field: some View {
        ZStack(alignment: .leading) {
            GrowingTextInput(
                text: $text, font: inputFont, textColor: UIColor(colors.colorsTextPrimaryDark),
                lineSpacing: textStyle.lineSpacing, accessibilityLabel: placeholder
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

    private var actionButton: some View {
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
    /// Editor UIKit dan placeholder memakai UIFont yang sama agar caret dan hint sejajar.
    var inputFont: UIFont { textStyle.uiFont }

    /// Equal single-line rows center the field/button; a taller field keeps the button at its bottom.
    var singleLineRowHeight: CGFloat {
        max(CustomSizes.Composer.sendButton.scaledToArtwork, ceil(inputFont.lineHeight + textStyle.lineSpacing))
    }

    var isSendEnabled: Bool {
        isEnabled && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
