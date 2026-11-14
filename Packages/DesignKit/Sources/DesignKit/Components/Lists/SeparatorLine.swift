//
//  SeparatorLine.swift
//  DesignKit
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI

/// Garis pemisah horizontal 1 pt selebar wadah, mis. di antara baris daftar, baris tabel, atau di atas composer.
/// Hiasan saja, jadi disembunyikan dari VoiceOver.
@MainActor
public struct SeparatorLine: View {
    @Environment(\.designColors) private var colors

    public init() {}

    public var body: some View {
        colors.colorsOutlineNetral
            .frame(height: FigmaSize.weightOutline.scaledToArtwork)
            .accessibilityHidden(true)
    }
}
