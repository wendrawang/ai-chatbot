//
//  String+Resource.swift
//  DesignKit
//
//  Created by Wendra on 17/10/26.
//

import Foundation
import RswiftResources

public extension String {
    /// Preserve host locale overrides, including region-to-script matching such as zh_CN -> zh-Hans.
    init(resource: StringResource, locale: Locale) {
        guard let languages = Self.languages(for: resource.source, locale: locale) else {
            self = resource()
            return
        }
        self.init(resource: resource, preferredLanguages: languages)
    }

    /// Sama seperti di atas untuk string berargumen, mis. `"Hi, %@!"`.
    init<Arg1: CVarArg>(format resource: StringResource1<Arg1>, locale: Locale, _ argument: Arg1) {
        let languages = Self.languages(for: resource.source, locale: locale) ?? [locale.identifier]
        self.init(format: resource, preferredLanguages: languages, locale: locale, argument)
    }
}

private extension String {
    static func languages(for source: StringResource.Source, locale: Locale) -> [String]? {
        guard let bundle = source.bundle else { return nil }
        var preferences = [locale.identifier]
        if let fallback = bundle.developmentLocalization { preferences.append(fallback) }
        return Bundle.preferredLocalizations(from: bundle.localizations, forPreferences: preferences)
    }
}
