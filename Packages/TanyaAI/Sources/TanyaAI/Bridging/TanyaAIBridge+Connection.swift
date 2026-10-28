//
//  TanyaAIBridge+Connection.swift
//  TanyaAI
//
//  Created by Wendra on 28/10/26.
//

import Foundation

extension TanyaAIBridge {
    /// Dijalankan `ChatScreen` lewat `.task` selama halaman tampil: init → history → SSE. Stream putus atau
    /// error yang bisa di-retry = jeda backoff lalu ulang dari init. Berhenti saat task dibatalkan (halaman
    /// ditutup), percakapan ditutup, sesi habis, atau error yang tidak bisa di-retry.
    func run() async {
        var backoff = ChatBackoff()
        while !Task.isCancelled {
            let delay: TimeInterval
            do {
                guard try await connectOnce(onLive: { backoff.reset() }) else {
                    connection = .closed
                    return
                }
                delay = backoff.nextDelay()
            } catch {
                guard !Task.isCancelled, let retryDelay = retryDelay(after: error, backoff: &backoff) else { return }
                delay = retryDelay
            }
            connection = .connecting
            try? await sleep(delay)
        }
    }
}

// MARK: - Connection

private extension TanyaAIBridge {
    /// Satu siklus. False = percakapan `CLOSED` (history tetap dimuat, stream tidak dibuka).
    /// True = stream berakhir normal dan perlu disambung ulang.
    func connectOnce(onLive: () -> Void) async throws -> Bool {
        let session = try JSONDecoder.wire.decode(WireEnvelope<WireInit>.self, from: await transport.initialize()).data
        let isSameConversation = conversationID == nil || conversationID == session.conversationId
        let history = try await catchUpHistory(
            conversationID: session.conversationId, latestSeq: isSameConversation ? messages.latestSeq : nil
        )
        replaceOrMerge(history, conversationID: session.conversationId)
        guard session.state != .closed else { return false }
        // Replay mulai setelah pesan terakhir di daftar: event di antara history dan stream tidak hilang,
        // duplikatnya digabung lewat `message_id`.
        let lines = transport.events(
            conversationID: session.conversationId, lastEventID: messages.latestSeq.map(String.init)
        )
        var parser = ServerSentEventParser()
        for try await line in lines {
            if connection != .live {
                connection = .live
                onLive()
            }
            if let event = parser.consume(line) {
                apply(ChatEvent(event))
            }
        }
        if let event = parser.flush() {
            apply(ChatEvent(event))
        }
        return true
    }

    /// Halaman terbaru dulu, lalu halaman lebih lama sampai bertemu `latestSeq` yang sudah ada di daftar.
    /// Daftar kosong (pertama dibuka) cukup satu halaman; halaman lebih lama dimuat saat paging (TODO).
    func catchUpHistory(conversationID: String, latestSeq: Int?) async throws -> [ChatMessage] {
        var collected: [ChatMessage] = []
        var before: String?
        repeat {
            let data = try await transport.history(
                conversationID: conversationID, before: before, limit: ChatWire.historyPageSize
            )
            let page = try JSONDecoder.wire.decode(WireEnvelope<WireHistoryPage>.self, from: data).data
            collected += page.messages.compactMap(ChatMessage.init(wire:))
            before = page.nextBefore
        } while before != nil && latestSeq.map { known in (collected.map(\.seq).min() ?? .min) > known } == true
        return collected
    }

    /// Nil = berhenti menyambung. 401 menyerahkan ke host; error lain yang `retryable:false` menutup percakapan.
    func retryDelay(after error: Error, backoff: inout ChatBackoff) -> TimeInterval? {
        guard case let .response(statusCode, body)? = error as? TanyaAITransportError else {
            return backoff.nextDelay()
        }
        let failure = try? JSONDecoder.wire.decode(WireError.self, from: body)
        guard failure?.isRetryable ?? ChatBackoff.isServerError(statusCode: statusCode) else {
            if ChatBackoff.isUnauthorized(statusCode: statusCode) {
                connection = .expired
                onSessionExpired?()
            } else {
                connection = .closed
            }
            return nil
        }
        return backoff.nextDelay(retryAfterMilliseconds: failure?.data?.retryAfterMs)
    }
}
