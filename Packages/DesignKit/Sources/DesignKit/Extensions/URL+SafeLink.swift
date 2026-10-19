//
//  URL+SafeLink.swift
//  DesignKit
//
//  Created by Wendra on 19/10/26.
//

import Foundation

public extension URL {
    /// URL dari target link markup/action; nil untuk scheme berbahaya atau target tidak valid.
    init?(safeLink target: String) {
        guard let url = MarkupParser.safeLink(target) else { return nil }
        self = url
    }
}
