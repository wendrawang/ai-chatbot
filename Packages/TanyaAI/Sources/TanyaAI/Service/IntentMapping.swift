//
//  IntentMapping.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import Foundation

/// Menerjemahkan JSON hasil inquiry BE satu intent menjadi blok jawaban.
/// Kontrak BE berubah → hanya mapping intent itu yang diubah.
protocol IntentMapping {
    func blocks(from data: Data, locale: Locale) throws -> [ChatBlock]
}

enum IntentMappings {
    /// Nil untuk intent yang belum didukung app; layar menampilkan pesan umum.
    static func mapping(for name: String) -> IntentMapping? {
        switch IntentName(rawValue: name) {
        case .reviewPortfolio: return ReviewPortfolioMapping()
        case nil: return nil
        }
    }
}
