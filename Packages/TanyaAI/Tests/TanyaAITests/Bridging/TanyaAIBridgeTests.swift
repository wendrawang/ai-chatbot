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

    /// Reconnect me-replay `turn_end` pertanyaan sebelumnya setelah pertanyaan baru dikirim: tetap terkunci.
    @Test
    func replayedTurnEndOfAnEarlierQuestionKeepsTheNewOneWaiting() async {
        let transport = FakeChatTransport()
        transport.sendResult = .success(WireFixture.ack(seq: 10))
        let bridge = makeBridge(transport)
        let task = Task { await bridge.run() }
        defer { task.cancel() }
        await waitUntil { bridge.connection == .live }
        #expect(await bridge.send("Pertanyaan kedua"))
        transport.emit(WireFixture.turnEndFrame(seq: 6))
        transport.emit(WireFixture.messageFrame(seq: 10, direction: "customer"))
        await waitUntil { bridge.messages.count == 1 }
        #expect(bridge.isAwaitingReply)
        #expect(!(await bridge.send("Pertanyaan ketiga")))
        transport.emit(WireFixture.turnEndFrame(seq: 12))
        await waitUntil { !bridge.isAwaitingReply }
    }

    /// Stream lebih cepat dari respons HTTP: `turn_end` sebelum ack tetap membuka kunci setelah ack tiba.
    @Test
    func turnEndThatArrivesBeforeTheAckStillUnlocks() async {
        let transport = FakeChatTransport()
        transport.sendResult = .success(WireFixture.ack(seq: 10))
        transport.beforeAck = { transport.emit(WireFixture.turnEndFrame(seq: 12)) }
        let bridge = makeBridge(transport)
        let task = Task { await bridge.run() }
        defer { task.cancel() }
        await waitUntil { bridge.connection == .live }
        #expect(await bridge.send("Cek Portfolio saya"))
        await waitUntil { !bridge.isAwaitingReply }
    }

    /// 401 saat kirim sama dengan 401 saat menyambung: host diberi tahu sekali, stream yang terbuka ditutup,
    /// tidak menyambung ulang, dan kirim berikutnya ditolak.
    @Test
    func unauthorizedSendClosesTheOpenStreamAndExpiresOnce() async {
        let transport = FakeChatTransport()
        transport.sendResult = .failure(
            TanyaAITransportError.response(statusCode: 401, body: WireFixture.error(isRetryable: false))
        )
        var expiredCount = 0
        let bridge = TanyaAIBridge(transport: transport, onSessionExpired: { expiredCount += 1 }, sleep: { _ in })
        let task = Task { await bridge.run() }
        defer { task.cancel() }
        await waitUntil { bridge.connection == .live }
        #expect(!(await bridge.send("Cek Portfolio saya")))
        await waitUntil { transport.closedStreams == 1 }
        await task.value
        #expect(bridge.connection == .expired)
        #expect(transport.calls.filter { $0 == "init" }.count == 1)
        #expect(!(await bridge.send("Lagi")))
        #expect(expiredCount == 1)
    }

    /// Respons kirim percakapan lama datang setelah reconnect ke percakapan lain dan kirim di sana:
    /// pertanyaan baru tidak berubah, jadi `turn_end` jawaban barunya tetap membuka kunci.
    @Test
    func lateSendResponseFromThePreviousConversationIsIgnored() async {
        let transport = FakeChatTransport()
        transport.initResults = [
            .success(WireFixture.initialize()), .success(WireFixture.initialize(conversationID: "lain"))
        ]
        transport.sendResult = .success(WireFixture.ack(seq: 10))
        transport.isHoldingAck = true
        let bridge = makeBridge(transport)
        let task = Task { await bridge.run() }
        defer { task.cancel() }
        await waitUntil { bridge.connection == .live }
        let lateSend = Task { await bridge.send("Pertanyaan lama") }
        await waitUntil { transport.isAckHeld }
        transport.drop()
        await waitUntil { bridge.conversationID == "lain" && bridge.connection == .live }
        #expect(!bridge.isAwaitingReply)
        transport.sendResult = .success(WireFixture.ack(seq: 2))
        #expect(await bridge.send("Pertanyaan baru"))
        transport.releaseAck()
        #expect(await lateSend.value)
        #expect(bridge.isAwaitingReply)
        transport.emit(WireFixture.turnEndFrame(seq: 3))
        await waitUntil { !bridge.isAwaitingReply }
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
