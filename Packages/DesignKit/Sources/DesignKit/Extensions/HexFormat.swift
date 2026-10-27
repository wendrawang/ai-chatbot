//
//  HexFormat.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import Foundation

/// Spesifikasi format hex untuk `Color(hex:)`. Angka di sini aturan format, bukan nilai desain.
enum HexFormat {
    static let prefix = "#"
    static let radix = 16
    static let digitsPerChannel = 2
    static let channelMaximum: Double = 255
    static let opaqueAlpha = "FF"
    /// RGB: satu digit per kanal tanpa alpha.
    static let shortLength = HexChannel.allCases.count - 1
    /// RRGGBB: dua digit per kanal tanpa alpha.
    static let opaqueLength = shortLength * digitsPerChannel
    /// AARRGGBB: bentuk lengkap yang dibaca per kanal.
    static let fullLength = HexChannel.allCases.count * digitsPerChannel

    /// Ubah RGB/RRGGBB/AARRGGBB menjadi AARRGGBB; nil bila panjang atau karakter tidak valid.
    static func normalizedDigits(_ hex: String) -> String? {
        var digits = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if digits.hasPrefix(prefix) { digits.removeFirst(prefix.count) }
        guard digits.allSatisfy(\.isHexDigit) else { return nil }
        if digits.count == shortLength {
            digits = digits.map { String(repeating: $0, count: digitsPerChannel) }.joined()
        }
        if digits.count == opaqueLength { digits = opaqueAlpha + digits }
        return digits.count == fullLength ? digits : nil
    }

    /// Nilai kanal 0...1 dari string AARRGGBB.
    static func value(of channel: HexChannel, in digits: String) -> Double? {
        let start = digits.index(digits.startIndex, offsetBy: channel.rawValue * digitsPerChannel)
        let end = digits.index(start, offsetBy: digitsPerChannel)
        return UInt8(digits[start..<end], radix: radix).map { Double($0) / channelMaximum }
    }
}
