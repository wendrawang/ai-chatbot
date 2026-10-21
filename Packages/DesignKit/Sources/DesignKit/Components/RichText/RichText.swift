//
//  RichText.swift
//  DesignKit
//
//  Created by Wendra on 19/10/26.
//

import SwiftUI

/// Teks jawaban dengan markup bold/strike/color/link, dirender native (tanpa HTML).
/// Link tampil merah bergaris bawah; ketukan diteruskan ke `onOpenLink`, bukan Safari.
@MainActor
public struct RichText: View {
    @Environment(\.designColors)
    private var colors
    private let markup: String
    private let textColor: Color?
    private let onOpenLink: (URL) -> Void

    /// `textColor` nil memakai warna teks utama palette.
    public init(_ markup: String, textColor: Color? = nil, onOpenLink: @escaping (URL) -> Void) {
        self.markup = markup
        self.textColor = textColor
        self.onOpenLink = onOpenLink
    }

    public var body: some View {
        Text(attributedText)
            .font(FontFace.firaSansRegular.scaledFont(size: FigmaSize.typographySizeDisplaySmall14))
            .lineSpacing(lineSpacing)
            .foregroundColor(textColor ?? colors.colorsTextPrimaryDark)
            .tint(colors.colorsButtonActive)
            .fixedSize(horizontal: false, vertical: true)
            .environment(
                \.openURL,
                OpenURLAction { url in
                    onOpenLink(url)
                    return .handled
                })
    }
}

// MARK: - Helpers

private extension RichText {
    var attributedText: AttributedString {
        MarkupParser.runs(from: markup).reduce(into: AttributedString()) { result, run in
            var piece = AttributedString(run.text)
            if run.style.isBold {
                piece.font = FontFace.firaSansSemiBold.scaledFont(size: FigmaSize.typographySizeDisplaySmall14)
            }
            if run.style.isStruckThrough { piece.strikethroughStyle = .single }
            if let hex = run.style.colorHex {
                piece.foregroundColor = Color(hex: hex, fallback: textColor ?? colors.colorsTextPrimaryDark)
            }
            if let link = run.style.link {
                piece.link = link
                piece.underlineStyle = .single
                piece.foregroundColor = colors.colorsButtonActive
            }
            result += piece
        }
    }

    /// Jarak antarbaris agar tinggi baris sama dengan line height Figma 21.
    var lineSpacing: CGFloat {
        let font = FontFace.firaSansRegular.font(size: FigmaSize.typographySizeDisplaySmall14.scaledToArtwork)
        return max(.zero, FigmaSize.typographyLineHeightDisplaySmall14.scaledToArtwork - font.lineHeight)
    }
}
