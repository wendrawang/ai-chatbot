//
//  FilledButton.swift
//  DesignKit
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI

/// Tombol selebar wadah dengan latar gelap. `.regular` untuk aksi utama (Konfirmasi, Pilih); `.link` untuk teks kecil
/// bergaris bawah, mis. "Batalkan proses ini" di bawah kartu status. Copy dan aksi dari pemakai.
/// TODO: Konfirmasi warna, ukuran teks, dan tinggi dengan Figma; sementara dari foto.
@MainActor
public struct FilledButton: View {
    @Environment(\.designColors) private var colors
    @Environment(\.isEnabled) private var isEnvironmentEnabled
    private let title: String
    private let variant: FilledButtonVariant
    private let isEnabled: Bool
    private let onTap: () -> Void

    public init(
        title: String,
        variant: FilledButtonVariant = .regular,
        isEnabled: Bool = true,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.isEnabled = isEnabled
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(FontFace.firaSansSemiBold.swiftUIFont(size: fontSize))
                .underline(variant == .link)
                .foregroundColor(colors.colorsTextPrimaryLight)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: CustomSizes.Card.cornerRadius.scaledToArtwork)
                        .fill(isInteractive ? CustomColors.Button.muted : disabledColor)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

// MARK: - Helpers

private extension FilledButton {
    /// Parameter sendiri digabung dengan `.disabled` dari parent, supaya warnanya ikut nonaktif.
    var isInteractive: Bool {
        isEnabled && isEnvironmentEnabled
    }

    var fontSize: CGFloat {
        switch variant {
        case .regular:
            return FigmaSize.typographySizeDisplaySmall14.scaledToArtwork
        case .link:
            return FigmaSize.typographySizeDisplayTiny12.scaledToArtwork
        }
    }

    var verticalPadding: CGFloat {
        switch variant {
        case .regular:
            return CustomSizes.FilledButton.verticalPadding.scaledToArtwork
        case .link:
            return FigmaSize.spacingMedium.scaledToArtwork
        }
    }

    var horizontalPadding: CGFloat {
        switch variant {
        case .regular:
            return .zero
        case .link:
            return FigmaSize.spacingMedium.scaledToArtwork
        }
    }

    /// Warna nonaktif masing-masing tetap seperti sebelum kedua tombol digabung.
    var disabledColor: Color {
        switch variant {
        case .regular:
            return colors.colorsButtonDisable
        case .link:
            return colors.colorsIconDisabled
        }
    }
}
