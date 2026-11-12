//
//  FieldBox.swift
//  DesignKit
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI

/// Kotak isi field: padding dalam, sudut membulat, dan garis tepi. Nonaktif = latar abu-abu; tidak valid = garis
/// merah. Hanya permukaan; label dan error milik `FieldFrame`.
/// TODO: Cocokkan padding dan tinggi kotak dengan Figma; sementara dari foto.
struct FieldBox: ViewModifier {
    @Environment(\.designColors) private var colors
    let isEnabled: Bool
    let isInvalid: Bool

    func body(content: Content) -> some View {
        // Setinggi ikon chevron field pilihan, supaya field teks dan field pilihan sama tinggi.
        content
            .frame(minHeight: FigmaSize.weightIconSmall.scaledToArtwork)
            .padding(FigmaSize.spacingLarge.scaledToArtwork)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(shape.fill(isEnabled ? colors.colorsSurfacePrimary : colors.colorsSurfaceDisable))
            .overlay(shape.strokeBorder(outline, lineWidth: FigmaSize.weightOutline.scaledToArtwork))
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: CustomSizes.Card.cornerRadius.scaledToArtwork)
    }

    private var outline: Color {
        isInvalid ? colors.colorsOutlineRed : CustomColors.Stroke.color
    }
}
