//
//  String+Resource.swift
//  DesignKit
//
//  Created by Wendra on 17/10/26.
//

import Foundation

public extension String {
    /// Copy dari `Localizable.strings` di `bundle` sesuai locale host, bukan bahasa perangkat.
    /// Region dicocokkan ke script (zh_CN -> zh-Hans); bahasa yang tidak didukung jatuh ke
    /// development localization. Key yang tidak ada mengembalikan key itu sendiri.
    init(key: String, bundle: Bundle, locale: Locale) {
        var preferences = [locale.identifier]
        if let fallback = bundle.developmentLocalization { preferences.append(fallback) }
        let languages = Bundle.preferredLocalizations(from: bundle.localizations, forPreferences: preferences)
        let localized = languages.lazy
            .compactMap { bundle.path(forResource: $0, ofType: "lproj") }
            .compactMap(Bundle.init(path:))
            .first
        self = (localized ?? bundle).localizedString(forKey: key, value: nil, table: nil)
    }
}
