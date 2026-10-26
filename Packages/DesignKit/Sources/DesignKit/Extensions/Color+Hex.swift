//
//  Color+Hex.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import SwiftUI

public extension Color {
    /// Accepts RGB, RRGGBB or AARRGGBB. Invalid input uses an explicit, nonoptional fallback.
    init(hex: String, fallback: Color = .clear) {
        guard let digits = HexFormat.normalizedDigits(hex),
            let alpha = HexFormat.value(of: .alpha, in: digits),
            let red = HexFormat.value(of: .red, in: digits),
            let green = HexFormat.value(of: .green, in: digits),
            let blue = HexFormat.value(of: .blue, in: digits)
        else {
            self = fallback
            return
        }
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
