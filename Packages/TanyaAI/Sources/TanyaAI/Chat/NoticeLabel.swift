//
//  NoticeLabel.swift
//  TanyaAI
//
//  Created by Wendra on 26/10/26.
//

import DesignKit
import SwiftUI

/// Pesan gagal kirim/stop di atas composer.
@MainActor
struct NoticeLabel: View {
    @Environment(\.locale)
    private var locale
    @Environment(\.designColors)
    private var colors
    let notice: ChatNotice

    var body: some View {
        Text(message)
            .font(Font(FontFace.openSansRegular.font(size: FigmaSize.typographySizeDisplayTiny12.scaledToArtwork)))
            .foregroundColor(colors.colorsTextNegative)
            .padding(.top, FigmaSize.spacingMedium.scaledToArtwork)
            .padding(.horizontal, FigmaSize.spacingLarge.scaledToArtwork)
            .accessibilityIdentifier(ChatElementIdentifier.notice)
    }
}

// MARK: - Helpers

private extension NoticeLabel {
    var message: String {
        switch notice {
        case .sendFailed: return String(ChatCopy.sendFailed, locale: locale)
        case .stopFailed: return String(ChatCopy.stopFailed, locale: locale)
        }
    }
}
