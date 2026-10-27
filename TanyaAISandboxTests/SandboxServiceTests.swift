//
//  SandboxServiceTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 26/10/26.
//

import Foundation
import TanyaAI
import Testing

@testable import Tanya_AI_Sandbox

/// Service dummy sandbox mengikuti kontrak BE: `send` hanya menerima, pesan datang lewat stream.
struct SandboxServiceTests {
    @Test
    func sentChatComesBackThroughTheStreamBeforeItsAnswer() async throws {
        let service = SandboxChatService(options: SandboxOptions(arguments: []))
        let sessionId = try await session(of: service)
        var events = service.events(sessionId: sessionId).makeAsyncIterator()
        try await service.send("Cek saldo", sessionId: sessionId)
        let question = try await nextMessage(&events)
        #expect(question["role"] as? String == "user")
        #expect(question["text"] as? String == "Cek saldo")
        let answer = try await nextMessage(&events)
        #expect(answer["replyTo"] as? String == question["id"] as? String)
        #expect((answer["text"] as? String)?.contains("Saldo") == true)
    }

    @Test
    func cancelledChatGetsNoAnswer() async throws {
        let service = SandboxChatService(options: SandboxOptions(arguments: ["--slow-reply"]))
        let sessionId = try await session(of: service)
        var events = service.events(sessionId: sessionId).makeAsyncIterator()
        try await service.send("Promo", sessionId: sessionId)
        let question = try await nextMessage(&events)
        let questionId = try #require(question["id"] as? String)
        try await service.cancel(messageId: questionId, sessionId: sessionId)
        let history = try body(await service.history(sessionId: sessionId, before: nil))
        let messages = history["messages"] as? [[String: Any]] ?? []
        #expect(messages.map { $0["id"] as? String } == [questionId])
    }

    @Test
    func emptyConversationHasGreetingAndShortcuts() async throws {
        let service = SandboxChatService(options: SandboxOptions(arguments: []))
        let sessionId = try await session(of: service)
        let history = try body(await service.history(sessionId: sessionId, before: nil))
        #expect((history["messages"] as? [Any])?.isEmpty == true)
        let config = try body(await service.config(sessionId: sessionId))
        #expect((config["greeting"] as? String)?.isEmpty == false)
        #expect((config["shortcuts"] as? [Any])?.isEmpty == false)
    }

    @Test
    func longHistoryIsPagedFromTheNewest() async throws {
        let service = SandboxChatService(options: SandboxOptions(arguments: ["--long-history"]))
        let latest = try body(await service.history(sessionId: "session", before: nil))
        let latestMessages = latest["messages"] as? [[String: Any]] ?? []
        #expect(latestMessages.count == 20)
        #expect(latest["hasMore"] as? Bool == true)
        let oldestId = try #require(latestMessages.first?["id"] as? String)
        let older = try body(await service.history(sessionId: "session", before: oldestId))
        let olderMessages = older["messages"] as? [[String: Any]] ?? []
        #expect(olderMessages.count == 20)
        #expect(olderMessages.last?["id"] as? String != oldestId)
    }
}

// MARK: - Helpers

private extension SandboxServiceTests {
    func body(_ data: Data) throws -> [String: Any] {
        try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    func session(of service: SandboxChatService) async throws -> String {
        try #require(try body(await service.start())["sessionId"] as? String)
    }

    /// Event `message` berikutnya; heartbeat dilewati.
    func nextMessage(
        _ events: inout AsyncThrowingStream<TanyaAIServerEvent, Error>.Iterator
    ) async throws -> [String: Any] {
        while let event = try await events.next() {
            if event.name == "message" { return try body(event.data) }
        }
        throw URLError(.networkConnectionLost)
    }
}
