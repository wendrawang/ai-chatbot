//
//  LoadingIndicator.swift
//  DesignKit
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI

/// Spinner bawaan iOS berwarna ikon utama, untuk apa pun yang sedang dimuat: history pertama, ikon kartu, daftar
/// pilihan dari host. Posisi dan ukuran area milik pemakai.
@MainActor
public struct LoadingIndicator: View {
    @Environment(\.designColors) private var colors

    public init() {}

    public var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(colors.colorsIconColored)
    }
}
