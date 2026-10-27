//
//  ActionCard.swift
//  DesignKit
//
//  Created by Wendra on 27/10/26.
//

import SwiftUI

/// Kartu aksi satu ketukan: ikon di kotak, judul, deskripsi, dan chevron bulat.
/// Ikon disuplai caller (gambar lokal atau `RemoteImage`); copy juga dari caller.
@MainActor
public struct ActionCard<Icon: View>: View {
    @Environment(\.designColors)
    private var colors
    private let title: String
    private let description: String
    private let isEnabled: Bool
    private let onTap: () -> Void
    private let icon: Icon

    public init(
        title: String, description: String, isEnabled: Bool = true, onTap: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon
    ) {
        self.title = title
        self.description = description
        self.isEnabled = isEnabled
        self.onTap = onTap
        self.icon = icon()
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: FigmaSize.spacingLarge.scaledToArtwork) {
                iconBox
                texts
                chevron
            }
            .padding(FigmaSize.spacingLarge.scaledToArtwork)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityElement(children: .combine)
    }

    private var iconBox: some View {
        icon
            .frame(width: iconSize, height: iconSize)
            .frame(width: boxSize, height: boxSize)
            .background(
                RoundedRectangle(cornerRadius: CustomSizes.Card.cornerRadius.scaledToArtwork)
                    .fill(colors.colorsSurfaceWarning)
            )
            .accessibilityHidden(true)
    }

    private var texts: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacingSmall.scaledToArtwork) {
            Text(title)
                .font(Font(titleFont))
                .lineSpacing(titleFont.lineSpacing(forLineHeight: titleLineHeight))
                .foregroundColor(colors.colorsTextPrimaryDark)
            Text(description)
                .font(Font(descriptionFont))
                .lineSpacing(descriptionFont.lineSpacing(forLineHeight: descriptionLineHeight))
                .foregroundColor(colors.colorsTextSecondary)
        }
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Abu-abu saat nonaktif agar terlihat tidak bisa diketuk.
    private var chevron: some View {
        Image(DesignIcon.chevronRight).resizable().scaledToFit()
            .foregroundColor(colors.colorsIconLight)
            .frame(width: chevronSize, height: chevronSize)
            .background(Circle().fill(isEnabled ? colors.colorsButtonActive : colors.colorsIconDisabled))
            .accessibilityHidden(true)
    }
}

// MARK: - Helpers

private extension ActionCard {
    var iconSize: CGFloat { FigmaSize.weightIconSmall.scaledToArtwork }
    var boxSize: CGFloat { CustomSizes.ActionCard.iconBox.scaledToArtwork }
    var chevronSize: CGFloat { CustomSizes.ActionCard.chevron.scaledToArtwork }

    /// Display Small 14/21. TODO: Cocokkan role tipografi dengan Figma; sementara estimasi dari screenshot.
    var titleFont: UIFont {
        FontFace.firaSansSemiBold.font(size: FigmaSize.typographySizeDisplaySmall14.scaledToArtwork)
    }

    var titleLineHeight: CGFloat { FigmaSize.typographyLineHeightDisplaySmall14.scaledToArtwork }

    /// Display Tiny 12/18.
    var descriptionFont: UIFont {
        FontFace.openSansRegular.font(size: FigmaSize.typographySizeDisplayTiny12.scaledToArtwork)
    }

    var descriptionLineHeight: CGFloat { FigmaSize.typographyLineHeightDisplayTiny12.scaledToArtwork }
}
