//
//  LatestMessageButton.swift
//  TanyaAI
//
//  Created by Wendra on 27/11/26.
//

import DesignKit
import SwiftUI

/// Tombol panah ke pesan terbaru. Mengambang di tengah, tepat di atas composer; halaman yang menentukan kapan tampil
/// (selama ujung daftar di luar layar).
/// TODO: Konfirmasi jarak ke composer dengan Figma; sementara perkiraan dari foto.
@MainActor
struct LatestMessageButton: View {
    @Environment(\.locale) private var locale
    let onTap: () -> Void

    var body: some View {
        FloatingIconButton(icon: .arrowDown, onTap: onTap)
            .accessibilityLabel(String(ChatCopy.scrollToLatest, locale: locale))
            .padding(.bottom, FigmaSize.spacingLarge.scaledToArtwork)
            .accessibilityIdentifier(ChatElementIdentifier.scrollToLatest)
    }
}
