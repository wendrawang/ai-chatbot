//
//  FileCard.swift
//  DesignKit
//
//  Created by Wendra on 27/11/26.
//

import SwiftUI

/// Kartu satu file di antara pesan: kotak ikon, nama file satu baris (dipotong di tengah supaya ekstensi tetap
/// terlihat), lalu baris status dari `FileCardStatus`. Seluruh kartu adalah tombol yang tidak menerima sentuhan selama
/// diproses; arti ketukan milik pemakai (mis. buka detail atau kirim ulang). Lebar tetap; rata kiri-kanan milik
/// pemakai.
/// TODO: Cocokkan ukuran, warna kotak ikon, dan peran teks dengan Figma; sementara mengikuti mockup tim iOS.
@MainActor
public struct FileCard: View {
    @Environment(\.designColors) private var colors
    private let name: String
    private let status: FileCardStatus
    private let onTap: () -> Void

    public init(name: String, status: FileCardStatus, onTap: @escaping () -> Void) {
        self.name = name
        self.status = status
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: FigmaSize.spacingMedium.scaledToArtwork) {
                iconBox
                texts
            }
            .padding(FigmaSize.spacingMedium.scaledToArtwork)
            .frame(width: CustomSizes.FileCard.width.scaledToArtwork, alignment: .leading)
            .cardStyle(isElevated: false, outlineColor: outlineColor)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        // Bukan `.disabled`: gaya plain memudarkan kartu nonaktif, padahal status kirim harus tetap terbaca.
        .allowsHitTesting(!status.isSending)
        .accessibilityElement(children: .combine)
    }

    /// Spinner menggantikan ikon selama diproses, jadi baris status tetap setinggi teks.
    private var iconBox: some View {
        ZStack {
            if status.isSending {
                LoadingIndicator()
            } else {
                Image(DesignIcon.document).resizable().scaledToFit()
                    .foregroundColor(status.isFailed ? colors.colorsIconFailed : colors.colorsIconColored)
                    .frame(width: iconSize, height: iconSize)
            }
        }
        .frame(width: boxSize, height: boxSize)
        .cardStyle(isOutlined: false, isElevated: false, fillColor: colors.colorsSurfaceDisable)
        .accessibilityHidden(true)
    }

    private var texts: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacingSmall.scaledToArtwork) {
            Text(name)
                .designFont(.bodyStrong)
                .foregroundColor(colors.colorsTextPrimaryDark)
                .lineLimit(CustomTextLines.fileCard)
                .truncationMode(.middle)
            statusLine
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statusLine: some View {
        HStack(spacing: FigmaSize.spacingSmall.scaledToArtwork) {
            Text(status.note)
                .foregroundColor(status.isFailed ? colors.colorsTextNegative : colors.colorsTextSecondary)
            if let action = status.action {
                Text(action)
                    .foregroundColor(colors.colorsTextHyperlink)
            }
        }
        .designFont(.caption)
        .lineLimit(CustomTextLines.fileCard)
    }
}

// MARK: - Helpers

private extension FileCard {
    var outlineColor: Color { status.isFailed ? colors.colorsOutlineRed : CustomColors.Stroke.color }
    var iconSize: CGFloat { FigmaSize.weightIconSmall.scaledToArtwork }
    var boxSize: CGFloat { CustomSizes.FileCard.iconBox.scaledToArtwork }
}
