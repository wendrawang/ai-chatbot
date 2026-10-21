//
//  TextBubble.swift
//  DesignKit
//
//  Created by Wendra on 19/10/26.
//

import SwiftUI

/// Bubble pesan pengguna: latar merah, rata kanan, teks putih.
@MainActor
public struct TextBubble: View {
    @Environment(\.designColors)
    private var colors
    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(FontFace.firaSansRegular.scaledFont(size: FigmaSize.typographySizeDisplaySmall14))
            .foregroundColor(colors.colorsTextPrimaryLight)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, CustomSizes.Bubble.horizontalPadding.scaledToArtwork)
            .padding(.vertical, FigmaSize.spacingMedium.scaledToArtwork)
            .background(
                RoundedRectangle(cornerRadius: CustomSizes.Bubble.cornerRadius.scaledToArtwork)
                    .fill(colors.colorsButtonActive)
            )
            .frame(maxWidth: CustomSizes.Bubble.maximumWidth.scaledToArtwork, alignment: .trailing)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .accessibilityIdentifier(ComponentIdentifier.Bubble.user)
    }
}
