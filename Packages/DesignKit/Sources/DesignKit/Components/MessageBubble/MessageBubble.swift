//
//  MessageBubble.swift
//  DesignKit
//
//  Created by Wendra on 28/10/26.
//

import SwiftUI

/// Satu pesan teks. Keluar (pengguna): bubble merah rata kanan, teks putih. Masuk: tanpa background,
/// selebar konten, rata kiri. Margin antar pesan milik daftar pemakai.
@MainActor
public struct MessageBubble: View {
    @Environment(\.designColors)
    private var colors
    private let text: String
    private let isOutgoing: Bool
    private let fontFace: FontFace

    public init(text: String, isOutgoing: Bool, fontFace: FontFace = .openSansRegular) {
        self.text = text
        self.isOutgoing = isOutgoing
        self.fontFace = fontFace
    }

    public var body: some View {
        Text(text)
            .font(fontFace.swiftUIFont(size: FigmaSize.typographySizeDisplaySmall14.scaledToArtwork))
            .foregroundColor(isOutgoing ? colors.colorsTextPrimaryLight : colors.colorsTextPrimaryDark)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, isOutgoing ? FigmaSize.spacingLarge.scaledToArtwork : .zero)
            .padding(.vertical, isOutgoing ? FigmaSize.spacingMedium.scaledToArtwork : .zero)
            .background(surface)
            .padding(.leading, isOutgoing ? CustomSizes.MessageBubble.outgoingLeadingInset.scaledToArtwork : .zero)
            .frame(maxWidth: .infinity, alignment: isOutgoing ? .trailing : .leading)
    }

    @ViewBuilder
    private var surface: some View {
        if isOutgoing {
            RoundedRectangle(cornerRadius: CustomSizes.MessageBubble.cornerRadius.scaledToArtwork)
                .fill(colors.colorsButtonActive)
        }
    }
}
