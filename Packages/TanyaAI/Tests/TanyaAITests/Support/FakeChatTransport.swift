//
//  FakeChatTransport.swift
//  TanyaAI
//
//  Created by Wendra on 28/10/26.
//

import Foundation

@testable import TanyaAI

/// Gateway tiruan. Init dan history diambil dari antrean (elemen terakhir dipakai ulang); setiap `events`
/// membuka stream baru yang diisi test lewat `emit`/`drop`, atau langsung dari `scriptedStreams`.
final class FakeChatTransport: TanyaAIChatTransport {
    var initResults: [Result<Data, Error>] = [.success(WireFixture.initialize())]
    var historyPages: [Data] = [WireFixture.history([])]
    /// Baris yang dikirim lalu stream ditutup dengan error koneksi; kosong = stream dibiarkan terbuka.
    var scriptedStreams: [[String]] = []
    var sendResult: Result<Data, Error> = .success(WireFixture.ack())
    private(set) var calls: [String] = []
    private var continuation: AsyncThrowingStream<String, Error>.Continuation?

    func initialize() async throws -> Data {
        calls.append("init")
        return try next(&initResults).get()
    }

    func history(conversationID: String, before: String?, limit: Int) async throws -> Data {
        calls.append("history:\(before ?? "latest")")
        return next(&historyPages)
    }

    func sendMessage(conversationID: String, clientMessageID: String, text: String) async throws -> Data {
        calls.append("send:\(text)")
        return try sendResult.get()
    }

    func events(conversationID: String, lastEventID: String?) -> AsyncThrowingStream<String, Error> {
        calls.append("events:\(lastEventID ?? "none")")
        return AsyncThrowingStream { continuation in
            // Gateway selalu membuka stream dengan komentar `: connected`.
            continuation.yield(": connected")
            guard self.scriptedStreams.isEmpty else {
                self.scriptedStreams.removeFirst().forEach { continuation.yield($0) }
                continuation.finish(throwing: URLError(.networkConnectionLost))
                return
            }
            self.continuation = continuation
        }
    }

    /// Baris SSE ke stream yang sedang terbuka.
    func emit(_ lines: [String]) {
        lines.forEach { continuation?.yield($0) }
    }

    /// Koneksi putus di tengah stream.
    func drop() {
        continuation?.finish(throwing: URLError(.networkConnectionLost))
        continuation = nil
    }

    private func next<Element>(_ queue: inout [Element]) -> Element {
        queue.count > 1 ? queue.removeFirst() : queue[0]
    }
}
