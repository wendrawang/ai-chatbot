//
//  ToggleRow.swift
//  DesignKit
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI

/// Baris label dengan switch di kanan, mis. "Tampilkan informasi saldo". Warna aktif = warna pilihan terpilih.
/// Nonaktif = switch tidak bisa diubah.
@MainActor
public struct ToggleRow: View {
    @Environment(\.designColors) private var colors
    @Binding private var isOn: Bool
    private let label: String
    private let isEnabled: Bool

    public init(label: String, isOn: Binding<Bool>, isEnabled: Bool = true) {
        self.label = label
        self._isOn = isOn
        self.isEnabled = isEnabled
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
            Text(label)
                .font(
                    FontFace.firaSansRegular.swiftUIFont(size: FigmaSize.typographySizeDisplaySmall14.scaledToArtwork)
                )
                .foregroundColor(colors.colorsTextPrimaryDark)
                .fixedSize(horizontal: false, vertical: true)
        }
        .tint(colors.colorsSelectionFilledSelected)
        .disabled(!isEnabled)
    }
}
