//
//  MarkdownCodeBlock.swift
//  DesignKit
//
//  Created by Wendra on 3/11/26.
//

import SwiftUI

/// Code block monospace berlatar; baris panjang di-scroll horizontal, tidak dipatahkan.
@MainActor
struct MarkdownCodeBlock: View {
    @Environment(\.designColors) private var colors
    let code: String
    let style: MarkdownTextStyle

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(code)
                .font(.system(size: style.codeSize, design: .monospaced))
                .foregroundColor(colors.colorsTextPrimaryDark)
                .fixedSize()
                .padding(FigmaSize.spacingMedium.scaledToArtwork)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(
            isOutlined: false,
            isElevated: false,
            cornerRadius: CustomSizes.Markdown.cornerRadius.scaledToArtwork,
            fillColor: colors.colorsSurfaceSelected
        )
    }
}
