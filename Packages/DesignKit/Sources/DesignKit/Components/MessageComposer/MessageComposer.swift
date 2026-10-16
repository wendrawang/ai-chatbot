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
    @Binding
    private var text: String
    // Figma typography follows artwork scaling only, independent of the user's text size setting.
    private let fontSize = FigmaSize.typographySizeDisplaySmall14.scaledToArtwork
    private let placeholder: String
    private let sendLabel: String
    private let isEnabled: Bool
    private let fontFace: FontFace
    private let colors: any FigmaColorProtocol
    private let onSend: () -> Void

    public init(
        text: Binding<String>, placeholder: String, sendLabel: String,
        isEnabled: Bool = InitialValues.isEnabled, fontFace: FontFace = .openSansRegular,
        colors: any FigmaColorProtocol = DefaultColorConstants(), onSend: @escaping () -> Void
    ) {
        self._text = text
        self.placeholder = placeholder
        self.sendLabel = sendLabel
        self.isEnabled = isEnabled
        self.fontFace = fontFace
        self.colors = colors
        self.onSend = onSend
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: actionPadding) {
            field
                .frame(minHeight: minimumRowHeight)
            actionButton
                .frame(minHeight: minimumRowHeight)
        }
        .padding(.leading, FigmaSize.spacingLarge.scaledToArtwork)
        .padding(.trailing, actionPadding)
        .padding(.vertical, actionPadding)
        .background(surface)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(ComponentID.composer)
    }

    private var field: some View {
        ZStack(alignment: .leading) {
            GrowingTextInput(
                text: $text, font: inputFont, textColor: UIColor(colors.colorsTextPrimaryDark),
                lineSpacing: lineSpacing, accessibilityLabel: placeholder
            )
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .accessibilityIdentifier(ComponentID.input)
            if text.isEmpty {
                Text(placeholder)
                    .font(Font(inputFont))
                    .lineLimit(CustomSizes.InputText.minimumLines)
                    .foregroundColor(colors.colorsTextSecondary)
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
            }
        }
        .padding(.vertical, CustomSizes.ActionButton.tapAreaInset)
    }

    private var actionButton: some View {
        Button(action: onSend) {
            SystemSymbol.send.image.resizable().scaledToFit()
                .padding(CustomSizes.ActionButton.iconInset.scaledToArtwork)
                .foregroundColor(colors.colorsIconLight)
                .frame(
                    width: CustomSizes.ActionButton.visualSize.scaledToArtwork,
                    height: CustomSizes.ActionButton.visualSize.scaledToArtwork
                )
                .background(Circle().fill(isSendEnabled ? colors.colorsButtonActive : colors.colorsIconDisabled))
                .frame(
                    width: CustomSizes.ActionButton.minimumTapSize.tapTargetInArtwork,
                    height: CustomSizes.ActionButton.minimumTapSize.tapTargetInArtwork
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isSendEnabled)
        .accessibilityLabel(sendLabel)
        .accessibilityIdentifier(ComponentID.send)
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
                    .strokeBorder(CustomColors.Stroke.color, lineWidth: FigmaSize.weightOutline.strokeInArtwork)
            )
    }

    private var inputFont: UIFont { fontFace.font(size: fontSize) }

    /// Measure spacing from the visible circle, allowing its larger tap target into the padding.
    private var actionPadding: CGFloat {
        max(InitialValues.zeroCGFloat, FigmaSize.spacingLarge.scaledToArtwork - CustomSizes.ActionButton.tapAreaInset)
    }

    /// Equal single-line rows center the field/button; a taller field keeps the button at its bottom.
    private var minimumRowHeight: CGFloat {
        let padding = CustomSizes.ActionButton.tapAreaInset
        let singleLineHeight = ceil(inputFont.lineHeight + lineSpacing) + padding + padding
        return max(CustomSizes.ActionButton.minimumTapSize.tapTargetInArtwork, singleLineHeight)
    }

    private var lineSpacing: CGFloat {
        let leading = FigmaSize.typographyLineHeightDisplaySmall14.scaledToArtwork
        return max(InitialValues.zeroCGFloat, leading - inputFont.lineHeight)
    }

    private var isSendEnabled: Bool {
        isEnabled && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
