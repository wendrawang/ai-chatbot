//
//  FilledButton.swift
//  DesignKit
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI

/// Tombol selebar wadah. `.regular` = latar gelap untuk aksi utama (Konfirmasi, Pilih); `.outlined` = ukuran sama,
/// hanya garis tepi, untuk aksi kedua di sampingnya (Batalkan); `.link` = teks kecil bergaris bawah, mis. "Batalkan
/// proses ini" di bawah kartu status. Copy dan aksi dari pemakai.
/// TODO: Konfirmasi warna, ukuran teks, tinggi, dan garis `.outlined` dengan Figma; sementara dari foto.
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
                .foregroundColor(variant == .outlined ? accentColor : colors.colorsTextPrimaryLight)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .frame(maxWidth: .infinity)
                .cardStyle(
                    isOutlined: variant == .outlined,
                    isElevated: false,
                    outlineColor: accentColor,
                    fillColor: variant == .outlined ? nil : accentColor
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

    /// Latar `.regular`/`.link`, atau garis dan teks `.outlined`; abu-abu saat nonaktif.
    var accentColor: Color {
        isInteractive ? CustomColors.Button.muted : disabledColor
    }

    var fontSize: CGFloat {
        switch variant {
        case .regular, .outlined:
            return FigmaSize.typographySizeDisplaySmall14.scaledToArtwork
        case .link:
            return FigmaSize.typographySizeDisplayTiny12.scaledToArtwork
        }
    }

    var verticalPadding: CGFloat {
        switch variant {
        case .regular, .outlined:
            return CustomSizes.FilledButton.verticalPadding.scaledToArtwork
        case .link:
            return FigmaSize.spacingMedium.scaledToArtwork
        }
    }

    var horizontalPadding: CGFloat {
        switch variant {
        case .regular, .outlined:
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
        case .outlined:
            return colors.colorsTextDisabled
        case .link:
            return colors.colorsIconDisabled
        }
    }
}
