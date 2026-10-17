//
//  DesignTextStyle.swift
//  DesignKit
//
//  Created by Wendra on 18/10/26.
//

import SwiftUI
import UIKit

/// Satu gaya teks Figma: face, ukuran dan line height dalam point artwork 375.
/// Komponen memakai preset peran (`.body`, `.screenTitle`) agar tidak merakit font sendiri.
/// Ukuran mengikuti `.scaledToArtwork` saja, tidak mengikuti Dynamic Type.
public struct DesignTextStyle: Equatable {
    public let face: FontFace
    public let size: CGFloat
    public let lineHeight: CGFloat

    public init(face: FontFace, size: CGFloat, lineHeight: CGFloat) {
        self.face = face
        self.size = size
        self.lineHeight = lineHeight
    }

    /// Dipakai juga oleh editor UIKit agar teks dan placeholder memakai metrik yang sama.
    public var uiFont: UIFont { face.font(size: size.scaledToArtwork) }

    public var font: Font { Font(uiFont) }

    /// Jarak tambahan antarbaris supaya tinggi satu baris sama dengan line height Figma.
    public var lineSpacing: CGFloat { max(.zero, lineHeight.scaledToArtwork - uiFont.lineHeight) }
}
