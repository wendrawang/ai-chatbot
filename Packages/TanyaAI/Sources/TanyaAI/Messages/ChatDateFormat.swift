//
//  ChatDateFormat.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import Foundation

/// Format tanggal pemisah pesan ("14 Oct 2026"), dilokalkan per bahasa host.
enum ChatDateFormat {
    static let template = "dMMMyyyy"

    static func text(for date: Date, locale: Locale) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter.string(from: date)
    }
}
