//
//  SandboxOptions.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 15/10/26.
//

import Foundation

/// Developer-only launch metadata. The host callback accepts drafts without contacting a backend.
struct SandboxOptions {
    static let fontFailure = "Font registration failed: "
    private static let languageFlag = "--language"
    private static let rejectFlag = "--reject-send"

    let locale: Locale?
    let isRejectingSend: Bool

    init(arguments: [String]) {
        isRejectingSend = arguments.contains(Self.rejectFlag)
        if let position = arguments.firstIndex(of: Self.languageFlag),
            arguments.indices.contains(arguments.index(after: position))
        {
            locale = Locale(identifier: arguments[arguments.index(after: position)])
        } else {
            locale = nil
        }
    }
}
