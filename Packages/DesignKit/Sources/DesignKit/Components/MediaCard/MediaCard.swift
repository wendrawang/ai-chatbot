//
//  MediaCard.swift
//  DesignKit
//
//  Created by Wendra on 19/10/26.
//

import SwiftUI

/// Gambar promosi dengan caption. Gambar dimuat `AsyncImage` bawaan iOS 15.
@MainActor
public struct MediaCard: View {
    @Environment(\.designColors)
    private var colors
    private let imageURL: URL?
    private let caption: String
    private let onTap: (() -> Void)?

    public init(imageURL: URL?, caption: String, onTap: (() -> Void)? = nil) {
        self.imageURL = imageURL
        self.caption = caption
        self.onTap = onTap
    }

    public var body: some View {
        Button {
            onTap?()
        } label: {
            card
        }
        .buttonStyle(.plain)
        .disabled(onTap == nil)
        .accessibilityIdentifier(ComponentIdentifier.Media.card)
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: .zero) {
            AsyncImage(url: imageURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                colors.colorsSurfaceSelected
            }
            .frame(
                width: CustomSizes.Media.width.scaledToArtwork, height: CustomSizes.Media.imageHeight.scaledToArtwork
            )
            .clipped()
            Text(caption)
                .font(FontFace.firaSansSemiBold.scaledFont(size: FigmaSize.typographySizeDisplaySmall14))
                .foregroundColor(colors.colorsTextPrimaryDark)
                .fixedSize(horizontal: false, vertical: true)
                .padding(CustomSizes.Media.captionPadding.scaledToArtwork)
        }
        .frame(width: CustomSizes.Media.width.scaledToArtwork, alignment: .leading)
        .background(colors.colorsSurfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: CustomSizes.Media.cornerRadius.scaledToArtwork))
        .shadow(
            color: CustomColors.Shadow.color, radius: CustomSizes.Shadow.radius.scaledToArtwork,
            y: CustomSizes.Shadow.offsetY.scaledToArtwork
        )
    }
}
