//
//  CardStyle.swift
//  DesignKit
//
//  Created by Wendra on 22/10/26.
//

import SwiftUI

/// Permukaan kartu standar: isi `colorsSurfacePrimary`, sudut membulat, garis tepi tipis, dan bayangan.
/// Hanya latar; padding isi tetap milik komponen pemakai.
struct CardStyle: ViewModifier {
    @Environment(\.designColors)
    private var colors

    func body(content: Content) -> some View {
        content.background(surface)
    }

    private var surface: some View {
        let shape = RoundedRectangle(cornerRadius: CustomSizes.Card.cornerRadius.scaledToArtwork)
        return
            shape
            .fill(colors.colorsSurfacePrimary)
            .designShadow()
            .overlay(shape.strokeBorder(CustomColors.Stroke.color, lineWidth: FigmaSize.weightOutline.scaledToArtwork))
    }
}
