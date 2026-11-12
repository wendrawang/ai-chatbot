//
//  FilledButton.swift
//  DesignKit
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI

/// Tombol utama selebar wadah dengan latar gelap, mis. Konfirmasi di form atau Pilih di daftar pilihan banyak.
/// Copy dan aksi dari pemakai. TODO: Konfirmasi warna, ukuran teks, dan tinggi dengan Figma; sementara dari foto.
@MainActor
public struct FilledButton: View {
    @Environment(\.designColors) private var colors
    private let title: String
    private let isEnabled: Bool
    private let onTap: () -> Void

    public init(title: String, isEnabled: Bool = true, onTap: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(
                    FontFace.firaSansSemiBold.swiftUIFont(size: FigmaSize.typographySizeDisplaySmall14.scaledToArtwork)
                )
                .foregroundColor(colors.colorsTextPrimaryLight)
                .padding(.vertical, CustomSizes.FilledButton.verticalPadding.scaledToArtwork)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: CustomSizes.Card.cornerRadius.scaledToArtwork)
                        .fill(isEnabled ? CustomColors.Button.muted : colors.colorsButtonDisable)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
