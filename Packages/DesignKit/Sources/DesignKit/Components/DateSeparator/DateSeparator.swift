//
//  DateSeparator.swift
//  DesignKit
//
//  Created by Wendra on 19/10/26.
//

import SwiftUI

/// Tanggal di tengah daftar pesan; teks sudah diformat oleh pemakai.
@MainActor
public struct DateSeparator: View {
    @Environment(\.designColors)
    private var colors
    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(FontFace.firaSansRegular.scaledFont(size: FigmaSize.typographySizeDisplayTiny12))
            .foregroundColor(colors.colorsTextSecondary)
            .frame(maxWidth: .infinity)
            .accessibilityIdentifier(ComponentIdentifier.Status.date)
    }
}
