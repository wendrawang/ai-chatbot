//
//  SelectField.swift
//  DesignKit
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI

/// Field pilihan: tampil seperti dropdown dan memanggil `onTap`, biasanya untuk membuka daftar pilihan di bottom sheet.
/// `value` nil = belum dipilih, jadi `placeholder` tampil abu-abu. Teks ringkasan untuk pilihan banyak (mis.
/// "Terpilih 3 rekening") disusun pemakai. `error` tampil merah di bawah kotak. Nonaktif = tidak bisa diketuk.
@MainActor
public struct SelectField: View {
    @Environment(\.designColors) private var colors
    private let label: String?
    private let value: String?
    private let placeholder: String
    private let error: String?
    private let isEnabled: Bool
    private let onTap: () -> Void

    public init(
        label: String? = nil,
        value: String?,
        placeholder: String,
        error: String? = nil,
        isEnabled: Bool = true,
        onTap: @escaping () -> Void
    ) {
        self.label = label
        self.value = value
        self.placeholder = placeholder
        self.error = error
        self.isEnabled = isEnabled
        self.onTap = onTap
    }

    public var body: some View {
        FieldFrame(label: label, error: error) {
            Button(action: onTap) {
                HStack(spacing: FigmaSize.spacingMedium.scaledToArtwork) {
                    text
                    chevron
                }
                .fieldBox(isEnabled: isEnabled, isInvalid: error != nil)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!isEnabled)
            .accessibilityLabel(label ?? placeholder)
            .accessibilityValue(value ?? String())
        }
    }

    private var text: some View {
        Text(value ?? placeholder)
            .font(FontFace.firaSansRegular.swiftUIFont(size: FigmaSize.typographySizeDisplayNormal16.scaledToArtwork))
            .foregroundColor(value == nil ? colors.colorsTextSecondary : colors.colorsTextPrimaryDark)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var chevron: some View {
        Image(DesignIcon.chevronDown).resizable().scaledToFit()
            .frame(width: FigmaSize.weightIconSmall.scaledToArtwork, height: FigmaSize.weightIconSmall.scaledToArtwork)
            .foregroundColor(isEnabled ? colors.colorsIconDark : colors.colorsIconDisabled)
            .accessibilityHidden(true)
    }
}
