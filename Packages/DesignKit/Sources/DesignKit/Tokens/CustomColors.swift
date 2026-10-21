//
//  CustomColors.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import SwiftUI

/// Semantic uses of additional colors. Generated colors remain the source for existing roles.
public enum CustomColors {
    public enum Stroke {
        public static let color = CustomBasePaletteColor.royalPastelBlue
    }

    /// Tombol penuh gelap "action-here" (C2, menunggu konfirmasi warna Figma).
    public enum FilledAction {
        public static let background = CustomBasePaletteColor.slateGray
    }

    public enum Shadow {
        public static let opacity: Double = 0.4
        public static let color = CustomBasePaletteColor.glossySilver.opacity(opacity)
    }
}
