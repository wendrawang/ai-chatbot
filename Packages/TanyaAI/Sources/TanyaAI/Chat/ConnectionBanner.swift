//
//  ConnectionBanner.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

import DesignKit
import SwiftUI

/// Status koneksi di atas composer: sedang menghubungkan, atau putus dengan tombol coba lagi.
@MainActor
struct ConnectionBanner: View {
    @Environment(\.locale)
    private var locale
    @Environment(\.designColors)
    private var colors
    let isFailed: Bool
    let onRetry: () -> Void

    var body: some View {
        HStack(spacing: FigmaSize.spacingSmall.scaledToArtwork) {
            Text(message)
                .foregroundColor(colors.colorsTextSecondary)
            if isFailed {
                Button(action: onRetry) {
                    Text(String(resource: R.string.localizable.chatRetry, locale: locale))
                        .foregroundColor(colors.colorsTextBrand)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(ChatElementIdentifier.retry)
            }
        }
        .font(Font(FontFace.openSansRegular.font(size: FigmaSize.typographySizeDisplayTiny12.scaledToArtwork)))
        .padding(.top, FigmaSize.spacingMedium.scaledToArtwork)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(ChatElementIdentifier.connection)
    }

    private var message: String {
        String(
            resource: isFailed ? R.string.localizable.chatDisconnected : R.string.localizable.chatConnecting,
            locale: locale
        )
    }
}
