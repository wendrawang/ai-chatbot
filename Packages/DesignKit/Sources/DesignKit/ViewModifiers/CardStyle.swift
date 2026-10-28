//
//  CardStyle.swift
//  DesignKit
//
//  Created by Wendra on 22/10/26.
//

import SwiftUI

/// Permukaan kartu standar: isi `colorsSurfacePrimary`, sudut membulat, bayangan, dan garis tepi tipis
/// bila `isOutlined`. Tanpa garis tepi, kartu hanya terangkat oleh bayangan (seperti CardView Android).
/// Hanya latar; padding isi tetap milik komponen pemakai.
struct CardStyle: ViewModifier {
    @Environment(\.designColors)
    private var colors
    let isOutlined: Bool

    func body(content: Content) -> some View {
        content.background(surface)
    }

    private var surface: some View {
        let shape = RoundedRectangle(cornerRadius: CustomSizes.Card.cornerRadius.scaledToArtwork)
        return
            shape
            .fill(colors.colorsSurfacePrimary)
            .designShadow()
            .overlay(shape.strokeBorder(outline, lineWidth: FigmaSize.weightOutline.scaledToArtwork))
    }

    private var outline: Color {
        isOutlined ? CustomColors.Stroke.color : .clear
    }
}
