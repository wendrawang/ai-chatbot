//
//  TanyaAIBridgeTests.swift
//  TanyaAI
//
//  Created by Wendra on 28/10/26.
//

import Foundation
import Testing

@testable import TanyaAI

/// Kirim: ack gateway hanya mengunci; pertanyaan dan jawaban tampil dari stream, `turn_end` membuka kunci.
@MainActor
@Suite(.serialized)
struct TanyaAIBridgeTests {
    @Test
    func questionAppearsOnlyFromTheStreamAndTurnEndUnlocksTheNextOne() async {
        let transport = FakeChatTransport()
        let bridge = makeBridge(transport)
        let task = Task { await bridge.run() }
        defer { task.cancel() }
        await waitUntil { bridge.connection == .live }

        #expect(await bridge.send("Cek Portfolio saya"))
        #expect(bridge.isAwaitingReply)
        #expect(bridge.messages.isEmpty)
        #expect(!(await bridge.send("Saya mau beli valas")))

        transport.emit(WireFixture.messageFrame(seq: 1) + WireFixture.messageFrame(seq: 2))
        await waitUntil { bridge.messages.count == 2 }
        #expect(bridge.messages.map(\.author) == [.customer, .bot])
        #expect(bridge.isAwaitingReply)

        transport.emit(WireFixture.turnEndFrame(seq: 3))
        await waitUntil { !bridge.isAwaitingReply }
        #expect(transport.calls.filter { $0.hasPrefix("send") } == ["send:Cek Portfolio saya"])
    }

    @Test
    func refusedSendKeepsTheDraftAndDoesNotWait() async {
        let transport = FakeChatTransport()
        transport.sendResult = .failure(TanyaAITransportError.response(statusCode: 400, body: Data()))
        let bridge = makeBridge(transport)
        let task = Task { await bridge.run() }
        defer { task.cancel() }
        await waitUntil { bridge.isReady }
        #expect(!(await bridge.send("Cek Portfolio saya")))
        #expect(!bridge.isAwaitingReply)
    }

    @Test
    func sendBeforeTheConversationExistsIsRefusedWithoutCallingTheGateway() async {
        let transport = FakeChatTransport()
        #expect(!(await makeBridge(transport).send("Cek Portfolio saya")))
        #expect(transport.calls.isEmpty)
    }

    /// Pesan pertama dari stream (mis. pertanyaan dari shortcut) langsung menggantikan sambutan.
    @Test
    func firstStreamedMessageHidesTheWelcome() async {
        let transport = FakeChatTransport()
        let bridge = makeBridge(transport)
        let task = Task { await bridge.run() }
        defer { task.cancel() }
        await waitUntil { bridge.connection == .live }
        #expect(bridge.isWelcomeVisible)
        transport.emit(WireFixture.messageFrame(seq: 1))
        await waitUntil { !bridge.isWelcomeVisible }
        #expect(bridge.messages.count == 1)
    }

    /// Halaman ditutup = task dibatalkan; stream ikut berakhir dan bridge tidak menyambung ulang.
    @Test
    func cancellingTheTaskStopsWithoutReconnecting() async {
        let transport = FakeChatTransport()
        let bridge = makeBridge(transport)
        let task = Task { await bridge.run() }
        await waitUntil { bridge.connection == .live }
        task.cancel()
        await task.value
        #expect(transport.calls.filter { $0 == "init" }.count == 1)
    }
}

// MARK: - Helpers

extension TanyaAIBridgeTests {
    func makeBridge(_ transport: FakeChatTransport) -> TanyaAIBridge {
        TanyaAIBridge(transport: transport, onSessionExpired: nil, sleep: { _ in })
    }
}
