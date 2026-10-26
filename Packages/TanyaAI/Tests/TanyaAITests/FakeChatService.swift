//
//  FakeChatService.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

import Foundation

@testable import TanyaAI

/// Service palsu yang dikendalikan test: menghitung panggilan dan memegang stream yang terbuka.
/// Seperti BE, `send` hanya menerima; test memancarkan pesan user dan jawaban lewat `emit`.
actor FakeChatService: TanyaAIService {
    private(set) var startCount = 0
    private(set) var historyCursors: [String?] = []
    private(set) var configCount = 0
    private(set) var sentTexts: [String] = []
    private(set) var cancelledIds: [String] = []
    private(set) var openedStreams = 0
    private(set) var closedStreams = 0
    var isStartFailing = false
    var isSendFailing = false
    var isCancelFailing = false
    /// Isi history per cursor `before`; nil = halaman terbaru.
    var pages: [String: Data] = [:]
    var latestPage = FakeChatService.page([], isMoreAvailable: false)
    var configData = Data(#"{"greeting":"Halo","shortcuts":[]}"#.utf8)
    private var continuation: AsyncThrowingStream<TanyaAIServerEvent, Error>.Continuation?

    func start() async throws -> Data {
        startCount += 1
        if isStartFailing { throw URLError(.notConnectedToInternet) }
        return Data(#"{"sessionId":"session-\#(startCount)"}"#.utf8)
    }

    func history(sessionId: String, before messageId: String?) async throws -> Data {
        historyCursors.append(messageId)
        guard let messageId else { return latestPage }
        return pages[messageId] ?? Self.page([], isMoreAvailable: false)
    }

    func config(sessionId: String) async throws -> Data {
        configCount += 1
        return configData
    }

    nonisolated func events(sessionId: String) -> AsyncThrowingStream<TanyaAIServerEvent, Error> {
        AsyncThrowingStream { continuation in
            continuation.onTermination = { _ in Task { await self.didClose() } }
            Task { await self.attach(continuation) }
        }
    }

    func send(_ text: String, sessionId: String) async throws {
        sentTexts.append(text)
        if isSendFailing { throw URLError(.timedOut) }
    }

    func cancel(messageId: String, sessionId: String) async throws {
        cancelledIds.append(messageId)
        if isCancelFailing { throw URLError(.timedOut) }
    }

    func setStartFailing(_ isFailing: Bool) { isStartFailing = isFailing }
    func setSendFailing(_ isFailing: Bool) { isSendFailing = isFailing }
    func setCancelFailing(_ isFailing: Bool) { isCancelFailing = isFailing }
    func setLatestPage(_ data: Data) { latestPage = data }
    func setPage(_ data: Data, before messageId: String) { pages[messageId] = data }
    func setConfig(_ data: Data) { configData = data }

    func emit(_ name: String, _ data: Data = Data("{}".utf8)) {
        continuation?.yield(TanyaAIServerEvent(name: name, data: data))
    }

    /// Menutup stream seperti koneksi SSE yang putus.
    func drop() {
        continuation?.finish()
        continuation = nil
    }

    private func didClose() {
        closedStreams += 1
    }

    private func attach(_ continuation: AsyncThrowingStream<TanyaAIServerEvent, Error>.Continuation) {
        openedStreams += 1
        self.continuation = continuation
    }
}

extension FakeChatService {
    static func message(
        id: String, role: String, text: String, replyTo: String? = nil, minute: Int = 0
    ) -> Data {
        Data(json(id: id, role: role, text: text, replyTo: replyTo, minute: minute).utf8)
    }

    static func page(_ messages: [String], isMoreAvailable: Bool) -> Data {
        Data(#"{"messages":[\#(messages.joined(separator: ","))],"hasMore":\#(isMoreAvailable)}"#.utf8)
    }

    static func json(id: String, role: String, text: String, replyTo: String? = nil, minute: Int = 0) -> String {
        let reply = replyTo.map { #","replyTo":"\#($0)""# } ?? ""
        let time = String(format: "2026-10-22T10:%02d:00Z", minute)
        return #"{"id":"\#(id)","role":"\#(role)","text":"\#(text)","createdAt":"\#(time)"\#(reply)}"#
    }
}
