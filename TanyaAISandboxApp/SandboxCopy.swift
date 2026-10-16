//
//  SandboxCopy.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 15/10/26.
//

import Foundation

/// Demo-host copy stays in the application bundle, outside the feature and DesignKit.
enum SandboxCopy: String {
    case open = "sandbox.open"

    private static let languages = ["en", "id", "zh-Hans"]
    private static let fileExtension = "lproj"

    func text(locale: Locale) -> String {
        let language =
            Bundle.preferredLocalizations(
                from: Self.languages, forPreferences: [locale.identifier]
            ).first ?? Self.languages[.zero]
        let localized =
            Bundle.main.path(forResource: language, ofType: Self.fileExtension)
            .flatMap(Bundle.init(path:)) ?? .main
        return localized.localizedString(forKey: rawValue, value: nil, table: nil)
    }
}
