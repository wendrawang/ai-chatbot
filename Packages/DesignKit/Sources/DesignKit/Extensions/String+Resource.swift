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
        guard let bundle = resource.source.bundle else {
            self = resource()
            return
        }
        var preferences = [locale.identifier]
        if let fallback = bundle.developmentLocalization { preferences.append(fallback) }
        let languages = Bundle.preferredLocalizations(from: bundle.localizations, forPreferences: preferences)
        self.init(resource: resource, preferredLanguages: languages)
    }
}
