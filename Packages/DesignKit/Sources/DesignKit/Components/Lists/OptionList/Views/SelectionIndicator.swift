//
//  SelectionIndicator.swift
//  DesignKit
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI

/// Penanda di kanan baris pilihan: radio untuk satu pilihan, kotak centang untuk banyak pilihan. Terpilih = warna
/// pilihan terpilih; belum = garis abu-abu.
@MainActor
struct SelectionIndicator: View {
    @Environment(\.designColors) private var colors
    let mode: OptionSelectionMode
    let isSelected: Bool

    var body: some View {
        mark
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var mark: some View {
        switch mode {
        case .single:
            Circle()
                .strokeBorder(outline, lineWidth: FigmaSize.weightOutline.scaledToArtwork)
                .overlay(radioDot)
        case .multiple:
            checkbox
        }
    }

    @ViewBuilder
    private var radioDot: some View {
        if isSelected {
            Circle()
                .fill(colors.colorsSelectionFilledSelected)
                .padding(CustomSizes.OptionList.radioDotInset.scaledToArtwork)
        }
    }

    @ViewBuilder
    private var checkbox: some View {
        let shape = RoundedRectangle(cornerRadius: CustomSizes.OptionList.checkboxCornerRadius.scaledToArtwork)
        if isSelected {
            shape
                .fill(colors.colorsSelectionFilledSelected)
                .overlay(
                    Image(DesignIcon.checkmark).resizable().scaledToFit()
                        .foregroundColor(colors.colorsIconLight)
                )
        } else {
            shape.strokeBorder(outline, lineWidth: FigmaSize.weightOutline.scaledToArtwork)
        }
    }

    private var outline: Color {
        isSelected ? colors.colorsSelectionFilledSelected : colors.colorsSelectionEmptyDefault
    }

    private var size: CGFloat { CustomSizes.OptionList.indicator.scaledToArtwork }
}
