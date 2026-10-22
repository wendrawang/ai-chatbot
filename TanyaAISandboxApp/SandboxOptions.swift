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
    static let detailOpenIdentifier = "sandbox.detail.open"
    static let detailTanyaAIIdentifier = "sandbox.detail.tanyaAI"
    static let offlineSimulateIdentifier = "sandbox.offline.simulate"
    static let offlineIdentifier = "sandbox.offline"
    static let offlineRetryIdentifier = "sandbox.offline.retry"
    static let logoutIdentifier = "sandbox.logout"
    static let loginIdentifier = "sandbox.login"
    static let demoStartIdentifier = "sandbox.demo.start"
    static let demoEndIdentifier = "sandbox.demo.end"
    static let demoParagraphCount = 12
    private static let languageFlag = "--language"
    private static let rejectFlag = "--reject-send"
    private static let headerDemoFlag = "--header-demo"
    private static let offlineFlag = "--offline"

    /// Opsi dari argumen peluncuran proses ini.
    static var current: SandboxOptions {
        SandboxOptions(arguments: ProcessInfo.processInfo.arguments)
    }

    let locale: Locale?
    let isRejectingSend: Bool
    let isHeaderDemo: Bool
    let isOffline: Bool

    init(arguments: [String]) {
        isRejectingSend = arguments.contains(Self.rejectFlag)
        isHeaderDemo = arguments.contains(Self.headerDemoFlag)
        isOffline = arguments.contains(Self.offlineFlag)
        if let position = arguments.firstIndex(of: Self.languageFlag),
            arguments.indices.contains(arguments.index(after: position))
        {
            locale = Locale(identifier: arguments[arguments.index(after: position)])
        } else {
            locale = nil
        }
    }
}
