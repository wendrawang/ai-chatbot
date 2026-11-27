//
//  TanyaAIBridgeAttachmentTests.swift
//  TanyaAI
//
//  Created by Wendra on 27/11/26.
//

import Foundation
import Testing

@testable import TanyaAI

/// Lampiran selama dilayani agen: kartu tampil saat itu juga, terkirim setelah ack tanpa menunggu stream, gagal bisa
/// dikirim ulang dengan id yang sama, dan salinan lokal tidak tertinggal di perangkat.
@MainActor
@Suite(.serialized)
struct TanyaAIBridgeAttachmentTests {
    @Test
    func cardShowsAtOnceAndIsSentAfterTheAck() async throws {
        let (transport, bridge) = await connectedBridge()
        defer { bridge.connectionTask?.cancel() }
        let delivery = bridge.sendAttachment(try pickedFile(named: "Slip.pdf"))
        let card = try #require(bridge.localQuestions.first)
        #expect(card.isSending, "tampil sebelum ack")
        #expect(card.attachment?.name == "Slip.pdf")
        #expect(bridge.latestSentQuestionID == card.id)
        #expect(!bridge.isAwaitingReply, "selama dilayani agen tidak ada turn lock")

        await delivery?.value
        #expect(bridge.localQuestions.first?.isSent == true)
        #expect(bridge.localQuestions.first?.seq == 2)
        let expected = TanyaAIAttachment(
            fileName: "Slip.pdf",
            mimeType: "application/pdf",
            base64Data: Data(content.utf8).base64EncodedString()
        )
        #expect(transport.lastAttachment == expected)
        #expect(transport.attachmentClientMessageIDs == [card.id])
    }

    @Test
    func failedCardIsRetriedWithTheSameID() async throws {
        let (transport, bridge) = await connectedBridge()
        defer { bridge.connectionTask?.cancel() }
        transport.attachmentResult = .failure(URLError(.notConnectedToInternet))
        await bridge.sendAttachment(try pickedFile(named: "KTP.jpg"))?.value
        let card = try #require(bridge.localQuestions.first)
        #expect(card.isFailed)
        #expect(bridge.connection == .live, "gagal kirim tidak memutus percakapan")

        transport.attachmentResult = .success(WireFixture.ack(seq: 5))
        let retry = bridge.retryAttachment(card.id)
        #expect(bridge.localQuestions.first?.isSending == true)
        await retry?.value
        #expect(bridge.localQuestions.map(\.id) == [card.id])
        #expect(bridge.localQuestions.first?.isSent == true)
        #expect(transport.attachmentClientMessageIDs == [card.id, card.id])
        #expect(bridge.retryAttachment(card.id) == nil, "kartu terkirim tidak dikirim ulang")
    }

    /// Bentuk pesan lampiran di stream belum ada: salinan tanpa tampilan tidak menghapus kartu dari daftar.
    @Test
    func streamCopyWithoutAViewKeepsTheCard() async throws {
        let (transport, bridge) = await connectedBridge()
        defer { bridge.connectionTask?.cancel() }
        await bridge.sendAttachment(try pickedFile(named: "Slip.pdf"))?.value
        let card = try #require(bridge.localQuestions.first)
        let copy = WireFixture.message(seq: 2, direction: "user", clientMessageID: card.id)
            .replacingOccurrences(of: #""payload":"pesan 2""#, with: #""payload":{"url":"https://example.com/f"}"#)
        transport.emit(["id: 2", "event: message", "data: \(copy)", ""])
        await waitUntil { bridge.messages.count == 1 }
        #expect(bridge.localQuestions.map(\.id) == [card.id])
        #expect(bridge.rows.map(\.id) == [card.id, "m-2"])
    }

    @Test
    func pickBeforeConnectingIsDiscarded() throws {
        let bridge = TanyaAIBridge(transport: FakeChatTransport(), onSessionExpired: nil, sleep: { _ in })
        let picked = try pickedFile(named: "Slip.pdf")
        #expect(bridge.sendAttachment(picked) == nil)
        #expect(bridge.localQuestions.isEmpty)
        #expect(!FileManager.default.fileExists(atPath: picked.url.path))
    }

    /// Salinan pindah ke folder milik bridge; percakapan berganti membuang salinannya, dan bridge yang dilepas
    /// menghapus foldernya.
    @Test
    func copiesLeaveWithTheConversationAndTheBridge() async throws {
        let (_, bridge) = await connectedBridge()
        await bridge.sendAttachment(try pickedFile(named: "Slip.pdf"))?.value
        let copy = try #require(bridge.localQuestions.first?.attachment?.url)
        #expect(copy.path.hasPrefix(bridge.attachmentFolder.path))
        bridge.replaceOrMerge([], conversationID: "percakapan-lain")
        #expect(!FileManager.default.fileExists(atPath: copy.path))
        bridge.connectionTask?.cancel()

        var released: TanyaAIBridge? = TanyaAIBridge(transport: FakeChatTransport(), onSessionExpired: nil)
        let folder = try #require(released?.attachmentFolder)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        released = nil
        #expect(!FileManager.default.fileExists(atPath: folder.path))
    }
}

// MARK: - Helpers

private extension TanyaAIBridgeAttachmentTests {
    var content: String { "isi lampiran" }

    func connectedBridge() async -> (FakeChatTransport, TanyaAIBridge) {
        let transport = FakeChatTransport()
        transport.initResults = [.success(WireFixture.initialize(state: "AGENT_ACTIVE"))]
        let bridge = TanyaAIBridge(transport: transport, onSessionExpired: nil, sleep: { _ in })
        Task { await bridge.run() }
        await waitUntil { bridge.connection == .live }
        return (transport, bridge)
    }

    /// Salinan seperti hasil picker: satu folder unik per file di folder sementara.
    func pickedFile(named name: String) throws -> ChatAttachmentFile {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let file = folder.appendingPathComponent(name)
        try Data(content.utf8).write(to: file)
        return ChatAttachmentFile(url: file)
    }
}
