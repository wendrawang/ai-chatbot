//
//  ChatCopy.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import Foundation

/// All screen copy is owned by this feature; DesignKit receives resolved labels.
enum ChatCopy: String, CaseIterable {
    case title = "chat.title"
    case back = "chat.back"
    case placeholder = "chat.placeholder"
    case send = "chat.send"

    private static let fileExtension = "lproj"

    func text(locale: Locale) -> String {
        let language =
            Bundle.preferredLocalizations(
                from: SupportedLanguage.allCases.map(\.rawValue), forPreferences: [locale.identifier]
            ).first ?? SupportedLanguage.english.rawValue
        let localized =
            Bundle.module.path(forResource: language, ofType: Self.fileExtension)
            .flatMap(Bundle.init(path:)) ?? .module
        return localized.localizedString(forKey: rawValue, value: nil, table: nil)
    }
}

enum SupportedLanguage: String, CaseIterable {
    case english = "en"
    case indonesian = "id"
    case simplifiedChinese = "zh-Hans"
}
