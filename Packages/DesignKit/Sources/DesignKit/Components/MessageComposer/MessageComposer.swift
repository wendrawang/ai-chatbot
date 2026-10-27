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
    private let isLoading: Bool
    private let fontFace: FontFace
    private let onSend: () -> Void

    public init(
        text: Binding<String>, placeholder: String, sendLabel: String,
        isEnabled: Bool = true, isLoading: Bool = false, fontFace: FontFace = .openSansRegular,
        onSend: @escaping () -> Void
    ) {
        self._text = text
        self.placeholder = placeholder
        self.sendLabel = sendLabel
        self.isEnabled = isEnabled
        self.isLoading = isLoading
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

    /// Saat `isLoading`, panah diganti titik bergerak dan tombol tidak bisa ditekan; draft tetap bisa diketik.
    private var actionButton: some View {
        Button(action: onSend) {
            actionIcon
                .frame(
                    width: CustomSizes.Composer.sendButton.scaledToArtwork,
                    height: CustomSizes.Composer.sendButton.scaledToArtwork
                )
                .background(Circle().fill(buttonFill))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isSendEnabled)
        .accessibilityLabel(sendLabel)
        .accessibilityIdentifier(ComponentIdentifier.Composer.send)
    }

    @ViewBuilder
    private var actionIcon: some View {
        if isLoading {
            LoadingDots(color: colors.colorsIconLight)
        } else {
            Image(DesignIcon.sendArrow).resizable().scaledToFit()
                .padding(CustomSizes.Composer.sendIconInset.scaledToArtwork)
                .foregroundColor(colors.colorsIconLight)
        }
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

    /// Merah saat bisa dikirim atau sedang menunggu; abu-abu saat draft kosong/nonaktif.
    var buttonFill: Color {
        isSendEnabled || isLoading ? colors.colorsButtonActive : colors.colorsIconDisabled
    }

    var isSendEnabled: Bool {
        isEnabled && !isLoading && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
