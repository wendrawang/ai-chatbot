//
//  MarkupSyntax.swift
//  DesignKit
//
//  Created by Wendra on 19/10/26.
//

/// Spesifikasi format markup; karakter di sini aturan format, bukan copy.
enum MarkupSyntax {
    static let open: Character = "["
    static let close: Character = "]"
    static let closingMark: Character = "/"
    static let divider: Character = "|"
    /// Scheme yang tidak pernah boleh bisa diketuk.
    static let blockedSchemes: Set<String> = ["javascript", "data", "file", "about"]
}
