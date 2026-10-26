//
//  SandboxChatFixture.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 22/10/26.
//

import Foundation

/// Isi `Resources/Fixtures/ChatDummy.json`: greeting, shortcut, history panjang, jawaban per kata kunci,
/// dan waktu tunda.
struct SandboxChatFixture: Decodable {
    let pageSize: Int
    /// Detik sebelum jawaban dikirim lewat stream.
    let replyDelay: Double
    /// Detik sebelum pesan user dipantulkan lewat stream setelah `send`.
    let echoDelay: Double
    /// Tunda jawaban untuk `--slow-reply` (menguji tombol stop).
    let slowReplyDelay: Double
    /// Detik antar event heartbeat.
    let heartbeatInterval: Double
    let messageEvent: String
    let heartbeatEvent: String
    /// Pengali history untuk `--long-history` (menguji paging dan scroll panjang).
    let longHistoryRepeat: Int
    let history: [SandboxFixtureEntry]
    let greeting: String
    let shortcuts: [SandboxShortcut]
    let replies: [SandboxFixtureReply]
    let fallback: String

    static func bundled() -> SandboxChatFixture? {
        R.file.chatDummyJson.url()
            .flatMap { try? Data(contentsOf: $0) }
            .flatMap { try? JSONDecoder().decode(SandboxChatFixture.self, from: $0) }
    }

    /// History `--long-history` dengan waktu mundur per menit dari sekarang, terlama lebih dulu.
    func longHistory() -> [SandboxMessage] {
        let entries = Array(repeating: history, count: longHistoryRepeat).flatMap { $0 }
        let now = Date()
        return entries.enumerated().map { index, entry in
            let minutesAgo = entries.count - index
            let createdAt = Calendar.current.date(byAdding: .minute, value: -minutesAgo, to: now) ?? now
            return SandboxMessage(role: entry.role, text: entry.text, createdAt: createdAt)
        }
    }

    /// Jawaban pertama yang kata kuncinya ada di pertanyaan; selain itu jawaban default.
    func reply(to question: String) -> String {
        let lowered = question.lowercased()
        return replies.first { $0.keywords.contains(where: lowered.contains) }?.text ?? fallback
    }
}
