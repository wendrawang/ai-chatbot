//
//  OptionRow.swift
//  DesignKit
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI

/// Satu baris di `OptionList`: teks pilihan, penanda di kanan, dan garis pemisah di bawahnya.
@MainActor
struct OptionRow: View {
    @Environment(\.designColors) private var colors
    let item: OptionItem
    let mode: OptionSelectionMode
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: FigmaSize.spacingMedium.scaledToArtwork) {
                Text(item.title)
                    .font(
                        FontFace.firaSansRegular.swiftUIFont(
                            size: FigmaSize.typographySizeDisplaySmall14.scaledToArtwork)
                    )
                    .foregroundColor(colors.colorsTextPrimaryDark)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                SelectionIndicator(mode: mode, isSelected: isSelected)
            }
            .padding(.vertical, FigmaSize.spacingLarge.scaledToArtwork)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) { separator }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var separator: some View {
        colors.colorsOutlineNetral
            .frame(height: FigmaSize.weightOutline.scaledToArtwork)
            .accessibilityHidden(true)
    }
}
