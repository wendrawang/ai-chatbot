//
//  ActionButton.swift
//  DesignKit
//
//  Created by Wendra on 19/10/26.
//

import SwiftUI

/// Tombol action di dalam jawaban. Satu komponen, empat gaya Figma:
/// `chip` (↳ + label), `suggestion` (prompt), `link` (merah bergaris bawah), `filled` (penuh gelap).
@MainActor
public struct ActionButton: View {
    @Environment(\.designColors)
    private var colors
    private let title: String
    private let style: Style
    private let isEnabled: Bool
    private let onTap: () -> Void

    public enum Style: Equatable {
        case chip, suggestion, link, filled
    }

    public init(_ title: String, style: Style, isEnabled: Bool = true, onTap: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.isEnabled = isEnabled
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            if style == .filled { filled } else { pill }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityIdentifier(ComponentIdentifier.Action.button)
    }

    private var pill: some View {
        HStack(spacing: FigmaSize.spacingMedium.scaledToArtwork) {
            if style == .chip {
                Image(R.image.replyArrow).resizable().scaledToFit()
                    .frame(
                        width: CustomSizes.Action.icon.scaledToArtwork, height: CustomSizes.Action.icon.scaledToArtwork
                    )
                    .foregroundColor(isEnabled ? colors.colorsIconColored : colors.colorsIconDisabled)
            }
            label(face: style == .suggestion ? .firaSansRegular : .firaSansSemiBold)
                .foregroundColor(pillTextColor)
        }
        .padding(.horizontal, FigmaSize.spacingLarge.scaledToArtwork)
        .frame(height: CustomSizes.Action.pillHeight.scaledToArtwork)
        .overlay(Capsule().strokeBorder(colors.colorsOutlineNetral, lineWidth: FigmaSize.weightOutline.scaledToArtwork))
        .contentShape(Capsule())
    }

    private var filled: some View {
        label(face: .firaSansSemiBold)
            .foregroundColor(colors.colorsTextPrimaryLight)
            .frame(maxWidth: .infinity)
            .frame(height: CustomSizes.Action.filledHeight.scaledToArtwork)
            .background(
                RoundedRectangle(cornerRadius: CustomSizes.Action.filledCornerRadius.scaledToArtwork)
                    .fill(isEnabled ? CustomColors.FilledAction.background : colors.colorsButtonDisable)
            )
    }

    private func label(face: FontFace) -> some View {
        Text(title)
            .font(face.scaledFont(size: FigmaSize.typographySizeDisplaySmall14))
            .underline(style == .link || style == .filled)
            .lineLimit(CustomTextLines.actionTitle)
    }
}

// MARK: - Helpers

private extension ActionButton {
    var pillTextColor: Color {
        guard isEnabled else { return colors.colorsTextDisabled }
        return style == .link ? colors.colorsButtonActive : colors.colorsTextPrimaryDark
    }
}
