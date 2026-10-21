//
//  ScrollToLatestButton.swift
//  DesignKit
//
//  Created by Wendra on 19/10/26.
//

import SwiftUI

/// Panah bulat untuk kembali ke pesan terbaru; label dari pemakai.
@MainActor
public struct ScrollToLatestButton: View {
    @Environment(\.designColors)
    private var colors
    private let label: String
    private let onTap: () -> Void

    public init(label: String, onTap: @escaping () -> Void) {
        self.label = label
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            Image(R.image.arrowDown).resizable().scaledToFit()
                .padding(FigmaSize.spacingMedium.scaledToArtwork)
                .foregroundColor(colors.colorsIconColored)
                .frame(
                    width: CustomSizes.ScrollToLatest.button.scaledToArtwork,
                    height: CustomSizes.ScrollToLatest.button.scaledToArtwork
                )
                .background(
                    Circle().fill(colors.colorsSurfacePrimary)
                        .shadow(
                            color: CustomColors.Shadow.color, radius: CustomSizes.Shadow.radius.scaledToArtwork,
                            y: CustomSizes.Shadow.offsetY.scaledToArtwork
                        )
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityIdentifier(ComponentIdentifier.Status.scrollToLatest)
    }
}
