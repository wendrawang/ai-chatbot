//
//  Color+Hex.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import SwiftUI

public extension Color {
    /// Accepts RGB, RRGGBB or AARRGGBB. Invalid input uses an explicit, nonoptional fallback.
    init(hex: String, fallback: Color = CustomColors.transparent) {
        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let digits = cleaned.hasPrefix("#") ? cleaned.dropFirst() : cleaned[...]
        let isValid = digits.utf8.allSatisfy { byte in
            (48...57).contains(byte) || (65...70).contains(byte) || (97...102).contains(byte)
        }
        guard [3, 6, 8].contains(digits.count), isValid,
            let value = UInt64(digits, radix: 16)
        else {
            self = fallback
            return
        }
        let alpha, red, green, blue: UInt64
        switch digits.count {
        case 3:
            (alpha, red, green, blue) = (255, ((value >> 8) & 0xF) * 17, ((value >> 4) & 0xF) * 17, (value & 0xF) * 17)
        case 6:
            (alpha, red, green, blue) = (255, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF)
        case 8:
            (alpha, red, green, blue) = ((value >> 24) & 0xFF, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF)
        default:
            self = fallback
            return
        }
        self.init(
            .sRGB, red: Double(red) / 255, green: Double(green) / 255,
            blue: Double(blue) / 255, opacity: Double(alpha) / 255)
    }
}
