//
//  SandboxChatService.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 22/10/26.
//

import Foundation
import TanyaAI

/// Peran host untuk sandbox: meniru BE (init, history berhalaman, SSE persistent dengan heartbeat,
/// kirim chat) dari fixture lokal. Di host asli, kelas ini memanggil endpoint dan membuka SSE.
actor SandboxChatService: TanyaAIService {
    private let fixture: SandboxChatFixture?
    private let isOffline: Bool
    private let onFailure: @Sendable (Error) -> Void
    private var messages: [SandboxMessage]
    private var continuation: AsyncThrowingStream<TanyaAIServerEvent, Error>.Continuation?

    /// `options.isOffline` meniru jaringan putus: setiap request gagal dan `onFailure` dipanggil.
    init(options: SandboxOptions, onFailure: @escaping @Sendable (Error) -> Void = { _ in }) {
        fixture = SandboxChatFixture.bundled()
        isOffline = options.isOffline
        self.onFailure = onFailure
        messages = fixture?.historyMessages(isLong: options.isLongHistory) ?? []
    }

    func start() async throws -> Data {
        try failIfOffline()
        return try Self.encode(SandboxSession(sessionId: UUID().uuidString))
    }

    func history(sessionId: String, before messageId: String?) async throws -> Data {
        try failIfOffline()
        let end = messageId.flatMap { id in messages.firstIndex { $0.id == id } } ?? messages.count
        let start = max(.zero, end - (fixture?.pageSize ?? end))
        return try Self.encode(SandboxHistory(messages: Array(messages[start..<end]), isMoreAvailable: start > .zero))
    }

    nonisolated func events(sessionId: String) -> AsyncThrowingStream<TanyaAIServerEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task { await self.keepAlive(continuation) }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func send(_ text: String, sessionId: String) async throws -> Data {
        try failIfOffline()
        let question = SandboxMessage(role: .user, text: text)
        messages.append(question)
        Task { await self.answer(question) }
        return try Self.encode(question)
    }
}

// MARK: - Helpers

private extension SandboxChatService {
    /// Stream tetap terbuka; heartbeat menandakan koneksi masih hidup.
    func keepAlive(_ continuation: AsyncThrowingStream<TanyaAIServerEvent, Error>.Continuation) async {
        self.continuation = continuation
        guard let fixture else { return }
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: Self.nanoseconds(fixture.heartbeatInterval))
            guard !Task.isCancelled else { return }
            continuation.yield(TanyaAIServerEvent(name: fixture.heartbeatEvent, data: Data()))
        }
    }

    func answer(_ question: SandboxMessage) async {
        guard let fixture else { return }
        try? await Task.sleep(nanoseconds: Self.nanoseconds(fixture.replyDelay))
        let reply = SandboxMessage(role: .assistant, text: fixture.reply(to: question.text), replyTo: question.id)
        messages.append(reply)
        guard let data = try? Self.encode(reply) else { return }
        continuation?.yield(TanyaAIServerEvent(name: fixture.messageEvent, data: data))
    }

    func failIfOffline() throws {
        guard isOffline else { return }
        let error = URLError(.notConnectedToInternet)
        onFailure(error)
        throw error
    }

    static func encode(_ value: some Encodable) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(value)
    }

    static func nanoseconds(_ seconds: Double) -> UInt64 {
        UInt64(seconds * Double(NSEC_PER_SEC))
    }
}
