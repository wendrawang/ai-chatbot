//
//  QuickActionRow.swift
//  DesignKit
//
//  Created by Wendra on 19/10/26.
//

import SwiftUI

/// Kartu shortcut: ikon dalam tile, judul, subjudul, dan chevron merah.
@MainActor
public struct QuickActionRow: View {
    @Environment(\.designColors)
    private var colors
    private let icon: Image
    private let title: String
    private let subtitle: String
    private let onTap: () -> Void

    public init(icon: Image, title: String, subtitle: String, onTap: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: CustomSizes.QuickAction.iconTextGap.scaledToArtwork) {
                iconTile
                labels
                chevron
            }
            .padding(FigmaSize.spacingLarge.scaledToArtwork)
            .background(surface)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(ComponentIdentifier.QuickAction.row)
    }

    private var iconTile: some View {
        icon.resizable().scaledToFit()
            .frame(width: FigmaSize.weightIconSmall.scaledToArtwork, height: FigmaSize.weightIconSmall.scaledToArtwork)
            .foregroundColor(colors.colorsIconColored)
            .frame(
                width: FigmaSize.weightIconMedium.scaledToArtwork, height: FigmaSize.weightIconMedium.scaledToArtwork
            )
            .background(
                RoundedRectangle(cornerRadius: CustomSizes.QuickAction.cornerRadius.scaledToArtwork)
                    .fill(colors.colorsSurfaceWarning)
            )
    }

    private var labels: some View {
        VStack(alignment: .leading, spacing: CustomSizes.QuickAction.titleGap.scaledToArtwork) {
            Text(title)
                .font(FontFace.firaSansSemiBold.scaledFont(size: FigmaSize.typographySizeDisplaySmall14))
                .foregroundColor(colors.colorsTextPrimaryDark)
            Text(subtitle)
                .font(FontFace.firaSansRegular.scaledFont(size: FigmaSize.typographySizeDisplayTiny12))
                .foregroundColor(colors.colorsTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var chevron: some View {
        Image(R.image.chevronRight).resizable().scaledToFit()
            .padding(FigmaSize.spacingSmall.scaledToArtwork)
            .foregroundColor(colors.colorsIconLight)
            .frame(
                width: CustomSizes.QuickAction.chevron.scaledToArtwork,
                height: CustomSizes.QuickAction.chevron.scaledToArtwork
            )
            .background(Circle().fill(colors.colorsButtonActive))
    }

    private var surface: some View {
        RoundedRectangle(cornerRadius: CustomSizes.QuickAction.cornerRadius.scaledToArtwork)
            .fill(colors.colorsSurfacePrimary)
            .shadow(
                color: CustomColors.Shadow.color, radius: CustomSizes.Shadow.radius.scaledToArtwork,
                y: CustomSizes.Shadow.offsetY.scaledToArtwork
            )
    }
}
