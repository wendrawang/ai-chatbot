//
//  ChatTurnTests.swift
//  TanyaAI
//
//  Created by Wendra on 26/10/26.
//

import Foundation
import Testing

@testable import TanyaAI

/// Kirim → pesan user dari stream → jawaban, serta stop.
@MainActor
struct ChatTurnTests {
    @Test
    func sentChatAppearsOnlyWhenTheStreamDeliversIt() async {
        let service = FakeChatService()
        let viewModel = await openedConversation(service)
        #expect(!viewModel.send("   "))
        #expect(viewModel.send(" Saldo saya? "))
        #expect(viewModel.turn == .sending)
        #expect(!viewModel.send("Pertanyaan kedua"))
        await waitUntil { await service.sentTexts == ["Saldo saya?"] }
        #expect(viewModel.messages.isEmpty)
        await service.emit("message", FakeChatService.message(id: "q1", role: "user", text: "Saldo saya?"))
        await waitUntil { viewModel.turn == .waiting(questionId: "q1") }
        #expect(viewModel.messages.map(\.id) == ["q1"])
        #expect(viewModel.deliveredQuestionId == "q1")
        await service.emit(
            "message", FakeChatService.message(id: "a1", role: "assistant", text: "Rp1", replyTo: "q1", minute: 1))
        await waitUntil { viewModel.turn == .idle }
        #expect(viewModel.messages.map(\.id) == ["q1", "a1"])
    }

    @Test
    func failedSendShowsANoticeAndAllowsSendingAgain() async {
        let service = FakeChatService()
        let viewModel = await openedConversation(service)
        await service.setSendFailing(true)
        #expect(viewModel.send("Transfer"))
        await waitUntil { viewModel.notice == .sendFailed }
        #expect(viewModel.turn == .idle)
        #expect(viewModel.messages.isEmpty)
        #expect(viewModel.deliveredQuestionId == nil)
        await service.setSendFailing(false)
        #expect(viewModel.send("Transfer"))
        #expect(viewModel.notice == nil)
    }

    @Test
    func stopCancelsTheAnswerAndIgnoresALateOne() async {
        let service = FakeChatService()
        let viewModel = await openedConversation(service)
        await ask("Promo?", as: "q1", in: viewModel, service: service)
        viewModel.stop()
        #expect(viewModel.turn == .stopping(questionId: "q1"))
        await waitUntil { viewModel.turn == .idle }
        let cancelled = await service.cancelledIds
        #expect(cancelled == ["q1"])
        #expect(viewModel.messages.first?.isAnswerStopped == true)
        await service.emit(
            "message", FakeChatService.message(id: "a1", role: "assistant", text: "Telat", replyTo: "q1", minute: 1))
        await service.emit("message", FakeChatService.message(id: "q2", role: "user", text: "Lain", minute: 2))
        await waitUntil { viewModel.messages.count == 2 }
        #expect(viewModel.messages.map(\.id) == ["q1", "q2"])
    }

    @Test
    func failedStopKeepsWaitingForTheAnswer() async {
        let service = FakeChatService()
        let viewModel = await openedConversation(service)
        await ask("Promo?", as: "q1", in: viewModel, service: service)
        await service.setCancelFailing(true)
        viewModel.stop()
        await waitUntil { viewModel.notice == .stopFailed }
        #expect(viewModel.turn == .waiting(questionId: "q1"))
        #expect(viewModel.messages.first?.isAnswerStopped == false)
    }

    @Test
    func answerArrivingWhileStoppingIsKept() async {
        let viewModel = await openedConversation()
        viewModel.receive(
            TanyaAIServerEvent(name: "message", data: FakeChatService.message(id: "q1", role: "user", text: "Promo?")))
        viewModel.turn = .stopping(questionId: "q1")
        viewModel.receive(
            TanyaAIServerEvent(
                name: "message",
                data: FakeChatService.message(id: "a1", role: "assistant", text: "Ini", replyTo: "q1", minute: 1)))
        viewModel.didStop("q1")
        #expect(viewModel.messages.map(\.id) == ["q1", "a1"])
        #expect(viewModel.messages.first?.isAnswerStopped == false)
        #expect(viewModel.turn == .idle)
    }

    @Test
    func shortcutsWorkOnlyInAnEmptyIdleConversation() async {
        let service = FakeChatService()
        let viewModel = await openedConversation(service)
        #expect(viewModel.isShortcutEnabled)
        #expect(viewModel.send("Cek saldo"))
        #expect(!viewModel.isShortcutEnabled)
        await service.emit("message", FakeChatService.message(id: "q1", role: "user", text: "Cek saldo"))
        await service.emit(
            "message", FakeChatService.message(id: "a1", role: "assistant", text: "Rp1", replyTo: "q1", minute: 1))
        await waitUntil { viewModel.turn == .idle }
        #expect(!viewModel.isShortcutEnabled)
    }
}
