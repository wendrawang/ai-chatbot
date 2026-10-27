//
//  ChatRecoveryTests.swift
//  TanyaAI
//
//  Created by Wendra on 27/10/26.
//

import Foundation
import Testing

@testable import TanyaAI

/// Reconnect, event ganda dan lifetime: kasus dari review yang direproduksi lebih dulu.
@MainActor
struct ChatRecoveryTests {
    @Test
    func reconnectWhileSendingFindsTheQuestionAndAnswerInHistory() async {
        let service = FakeChatService()
        let viewModel = await openedConversation(service)
        #expect(viewModel.send("Saldo?"))
        await waitUntil { await service.sentTexts == ["Saldo?"] }
        // BE menerima, tetapi stream putus sebelum pesan user sampai.
        await service.setLatestPage(
            FakeChatService.page(
                [
                    FakeChatService.json(id: "q1", role: "user", text: "Saldo?"),
                    FakeChatService.json(id: "a1", role: "assistant", text: "Rp1", replyTo: "q1", minute: 1)
                ], isMoreAvailable: false))
        await service.drop()
        await waitUntil { viewModel.messages.map(\.id) == ["q1", "a1"] }
        #expect(viewModel.turn == .idle)
        #expect(viewModel.deliveredQuestionId == "q1")
    }

    @Test
    func reconnectWhileSendingKeepsWaitingWhenOnlyTheQuestionIsInHistory() async {
        let service = FakeChatService()
        let viewModel = await openedConversation(service)
        #expect(viewModel.send("Saldo?"))
        await waitUntil { await service.sentTexts == ["Saldo?"] }
        await service.setLatestPage(
            FakeChatService.page(
                [FakeChatService.json(id: "q1", role: "user", text: "Saldo?")], isMoreAvailable: false))
        await service.drop()
        await waitUntil { viewModel.messages.map(\.id) == ["q1"] }
        #expect(viewModel.turn == .waiting(questionId: "q1"))
    }

    @Test
    func replayedQuestionDoesNotTakeOverTheNextOne() async {
        let service = FakeChatService()
        let viewModel = await openedConversation(service)
        await ask("Saldo?", as: "q1", in: viewModel, service: service)
        await service.emit(
            "message", FakeChatService.message(id: "a1", role: "assistant", text: "Rp1", replyTo: "q1", minute: 1))
        await waitUntil { viewModel.turn == .idle }
        #expect(viewModel.send("Promo?"))
        // Replay pesan user lama tidak boleh dianggap pantulan pertanyaan kedua.
        await service.emit("message", FakeChatService.message(id: "q1", role: "user", text: "Saldo?"))
        await service.emit("message", FakeChatService.message(id: "q2", role: "user", text: "Promo?", minute: 2))
        await waitUntil { viewModel.turn == .waiting(questionId: "q2") }
        await service.emit(
            "message", FakeChatService.message(id: "a2", role: "assistant", text: "Ada", replyTo: "q2", minute: 3))
        await waitUntil { viewModel.turn == .idle }
    }

    @Test
    func stoppedAnswerDoesNotComeBackThroughHistory() async {
        let service = FakeChatService()
        let viewModel = await openedConversation(service)
        await ask("Promo?", as: "q1", in: viewModel, service: service)
        viewModel.stop()
        await waitUntil { viewModel.turn == .idle }
        await service.setLatestPage(
            FakeChatService.page(
                [
                    FakeChatService.json(id: "q1", role: "user", text: "Promo?"),
                    FakeChatService.json(id: "a1", role: "assistant", text: "Telat", replyTo: "q1", minute: 1)
                ], isMoreAvailable: false))
        await service.drop()
        await waitUntil { await service.openedStreams == 2 }
        #expect(viewModel.messages.map(\.id) == ["q1"])
        #expect(viewModel.messages.first?.isAnswerStopped == true)
    }

    @Test
    func closedPageIsReleasedWhileTheFirstRequestIsStillRunning() async {
        let service = FakeChatService()
        await service.holdStart()
        weak var released: ChatViewModel?
        do {
            let viewModel = ChatViewModel(service: service)
            released = viewModel
            viewModel.start()
            await waitUntil { await service.startCount == 1 }
        }
        await waitUntil { released == nil }
        await service.releaseStart()
        // Halaman sudah ditutup: stream tidak boleh dibuka setelah request awal selesai.
        try? await Task.sleep(nanoseconds: 100_000_000)
        let openedStreams = await service.openedStreams
        #expect(openedStreams == 0)
    }
}
