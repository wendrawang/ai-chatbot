//
//  TanyaAIBridgeTests.swift
//  TanyaAI
//
//  Created by Wendra on 28/10/26.
//

import Testing

@testable import TanyaAI

/// Status menunggu jawaban milik TanyaAI: dimulai saat host menerima chat, berakhir saat percakapan baru.
@MainActor
struct TanyaAIBridgeTests {
    @Test
    func acceptedSendWaitsForReplyAndRefusesTheNextQuestionWithoutAskingTheHost() {
        var sent: [String] = []
        let bridge = TanyaAIBridge { text in
            sent.append(text)
            return true
        }
        #expect(!bridge.isAwaitingReply)
        #expect(bridge.send("Cek Portfolio saya"))
        #expect(bridge.isAwaitingReply)
        #expect(!bridge.send("Saya mau beli valas"))
        #expect(sent == ["Cek Portfolio saya"])
    }

    @Test
    func refusedSendDoesNotWaitForReply() {
        let bridge = TanyaAIBridge { _ in false }
        #expect(!bridge.send("Cek Portfolio saya"))
        #expect(!bridge.isAwaitingReply)
    }

    @Test
    func newConversationEndsWaitingAndTellsTheHost() {
        var newConversationCount = 0
        let bridge = TanyaAIBridge(onNewConversation: { newConversationCount += 1 }, onSend: { _ in true })
        #expect(bridge.isNewConversationAvailable)
        _ = bridge.send("Cek Portfolio saya")
        bridge.startNewConversation()
        #expect(!bridge.isAwaitingReply)
        #expect(newConversationCount == 1)
        #expect(bridge.send("Saya mau beli valas"))
    }

    @Test
    func newConversationIsUnavailableWithoutAHostHandler() {
        #expect(!TanyaAIBridge { _ in true }.isNewConversationAvailable)
    }
}
