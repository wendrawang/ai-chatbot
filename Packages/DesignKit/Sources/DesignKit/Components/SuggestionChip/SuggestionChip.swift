//
//  SuggestionChip.swift
//  DesignKit
//
//  Created by Wendra on 26/10/26.
//

import SwiftUI

/// Pilihan cepat berupa teks dengan garis tepi. Warna teks mengikuti status aktif tombol.
@MainActor
public struct SuggestionChip: View {
    @Environment(\.designColors)
    private var colors
    @Environment(\.isEnabled)
    private var isEnabled
    private let title: String
    private let action: () -> Void

    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(Font(FontFace.openSansRegular.font(size: FigmaSize.typographySizeDisplaySmall14.scaledToArtwork)))
                .foregroundColor(isEnabled ? colors.colorsTextPrimaryDark : colors.colorsTextDisabled)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, FigmaSize.spacingLarge.scaledToArtwork)
                .padding(.vertical, FigmaSize.spacingMedium.scaledToArtwork)
                .background(surface)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(ComponentIdentifier.Suggestion.root)
    }

    private var surface: some View {
        let shape = RoundedRectangle(cornerRadius: CustomSizes.Card.cornerRadius.scaledToArtwork)
        return shape.fill(colors.colorsSurfacePrimary)
            .overlay(shape.strokeBorder(CustomColors.Stroke.color, lineWidth: FigmaSize.weightOutline.scaledToArtwork))
    }
}
