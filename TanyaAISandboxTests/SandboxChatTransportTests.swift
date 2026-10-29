//
//  SandboxChatTransportTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 28/10/26.
//

import Foundation
import TanyaAI
import Testing

@testable import Tanya_AI_Sandbox

/// Gateway tiruan: ack dulu, lalu pertanyaan dan jawaban lewat stream, diakhiri `turn_end`.
@MainActor
struct SandboxChatTransportTests {
    @Test
    func acceptedQuestionComesBackOnTheStreamWithAReplyAndTurnEnd() async throws {
        let transport = makeTransport()
        var lines = try await openStream(transport)
        _ = try await transport.sendMessage(conversationID: "c", clientMessageID: "c-1", text: "Cek Portfolio saya")
        var received: [String] = []
        while received.filter({ $0.hasPrefix("event:") }).count < 3, let line = try await lines.next() {
            received.append(line)
        }
        #expect(received.filter { $0.hasPrefix("event:") } == ["event: message", "event: message", "event: turn_end"])
        #expect(received.filter { $0.contains("Cek Portfolio saya") }.count == 2)
    }

    @Test
    func rejectedSendThrowsANonRetryableBadRequest() async {
        let transport = makeTransport(arguments: ["--reject-send"])
        await #expect(throws: TanyaAITransportError.self) {
            try await transport.sendMessage(conversationID: "c", clientMessageID: "c-1", text: "x")
        }
    }

    @Test
    func offlineSendTellsTheHostBlocker() async {
        var failures: [Error] = []
        let transport = SandboxChatTransport(options: SandboxOptions(arguments: ["--offline"])) { failures.append($0) }
        await #expect(throws: URLError.self) {
            try await transport.sendMessage(conversationID: "c", clientMessageID: "c-1", text: "x")
        }
        #expect(failures.count == 1)
    }
}

// MARK: - Helpers

private extension SandboxChatTransportTests {
    func makeTransport(arguments: [String] = []) -> SandboxChatTransport {
        SandboxChatTransport(options: SandboxOptions(arguments: arguments)) { _ in }
    }

    /// Stream terbuka setelah `: connected`; continuation dipasang di main actor sesaat setelahnya.
    func openStream(_ transport: SandboxChatTransport) async throws -> AsyncThrowingStream<String, Error>.Iterator {
        var lines = transport.events(conversationID: "c", lastEventID: nil).makeAsyncIterator()
        #expect(try await lines.next() == ": connected")
        try await Task.sleep(nanoseconds: 50_000_000)
        return lines
    }
}
