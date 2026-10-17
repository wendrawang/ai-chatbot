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
    static let openIdentifier = "sandbox.open"
    static let demoStartIdentifier = "sandbox.demo.start"
    static let demoEndIdentifier = "sandbox.demo.end"
    static let demoParagraphCount = 12
    private static let languageFlag = "--language"
    private static let rejectFlag = "--reject-send"
    private static let headerDemoFlag = "--header-demo"

    let locale: Locale?
    let isRejectingSend: Bool
    let isHeaderDemo: Bool

    init(arguments: [String]) {
        isRejectingSend = arguments.contains(Self.rejectFlag)
        isHeaderDemo = arguments.contains(Self.headerDemoFlag)
        if let position = arguments.firstIndex(of: Self.languageFlag),
            arguments.indices.contains(arguments.index(after: position))
        {
            locale = Locale(identifier: arguments[arguments.index(after: position)])
        } else {
            locale = nil
        }
    }
}
