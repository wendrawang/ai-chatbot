//
//  SandboxOptions.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 15/10/26.
//

import Foundation

/// Developer-only launch metadata. Jawaban berasal dari fixture lokal tanpa backend.
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
    static let termsAcceptIdentifier = "sandbox.terms.accept"
    /// Kunci UserDefaults persetujuan T&C Tanya AI.
    static let termsAcceptedKey = "tanyaAI.terms.isAccepted"
    static let demoStartIdentifier = "sandbox.demo.start"
    static let demoEndIdentifier = "sandbox.demo.end"
    static let demoParagraphCount = 12
    private static let languageFlag = "--language"
    private static let offlineFlag = "--offline"
    private static let longHistoryFlag = "--long-history"
    private static let slowReplyFlag = "--slow-reply"
    private static let termsAcceptedFlag = "--terms-accepted"
    private static let termsResetFlag = "--reset-terms"

    /// Opsi dari argumen peluncuran proses ini.
    static var current: SandboxOptions {
        SandboxOptions(arguments: ProcessInfo.processInfo.arguments)
    }

    let locale: Locale?
    let isOffline: Bool
    /// History panjang untuk menguji paging dan scroll.
    let isLongHistory: Bool
    /// Jawaban lambat untuk menguji tombol stop.
    let isSlowReply: Bool
    /// T&C dianggap sudah disetujui sejak aplikasi dibuka.
    let isTermsAccepted: Bool
    /// Hapus persetujuan T&C saat aplikasi dibuka.
    let isTermsReset: Bool

    init(arguments: [String]) {
        isOffline = arguments.contains(Self.offlineFlag)
        isLongHistory = arguments.contains(Self.longHistoryFlag)
        isSlowReply = arguments.contains(Self.slowReplyFlag)
        isTermsAccepted = arguments.contains(Self.termsAcceptedFlag)
        isTermsReset = arguments.contains(Self.termsResetFlag)
        if let position = arguments.firstIndex(of: Self.languageFlag),
            arguments.indices.contains(arguments.index(after: position))
        {
            locale = Locale(identifier: arguments[arguments.index(after: position)])
        } else {
            locale = nil
        }
    }
}
