//
//  ChatViewModelTests.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

import Foundation
import Testing

@testable import TanyaAI

@MainActor
struct ChatViewModelTests {
    @Test
    func openingRunsStartThenHistoryThenKeepsTheStreamOpen() async {
        let service = FakeChatService()
        await service.setLatestPage(
            FakeChatService.page(
                [
                    FakeChatService.json(id: "m1", role: "user", text: "Halo", minute: 1),
                    FakeChatService.json(id: "m2", role: "assistant", text: "Hai", replyTo: "m1", minute: 2)
                ], isMoreAvailable: true))
        let viewModel = ChatViewModel(service: service)
        viewModel.start()
        viewModel.start()
        await waitUntil { viewModel.phase == .ready }
        await waitUntil { await service.openedStreams == 1 }
        let startCount = await service.startCount
        let cursors = await service.historyCursors
        #expect(startCount == 1)
        #expect(cursors == [nil])
        #expect(viewModel.messages.map(\.id) == ["m1", "m2"])
        #expect(viewModel.isMoreHistoryAvailable)
    }

    @Test
    func sendIsShownAtOnceThenConfirmedAndAnsweredThroughTheStream() async {
        let (service, viewModel) = await openedConversation()
        #expect(!viewModel.send("   "))
        #expect(viewModel.send(" Saldo saya? "))
        #expect(viewModel.messages.last?.text == "Saldo saya?")
        #expect(viewModel.messages.last?.delivery == .sending)
        await waitUntil { viewModel.messages.last?.id == "user-1" }
        #expect(viewModel.messages.last?.delivery == .sent)
        #expect(viewModel.isReplying)
        await service.emit(
            "message", FakeChatService.message(id: "a1", role: "assistant", text: "Rp1", replyTo: "user-1"))
        await waitUntil { viewModel.messages.last?.id == "a1" }
        #expect(!viewModel.isReplying)
    }

    @Test
    func heartbeatAndRepeatedMessagesLeaveTheListUnchanged() async {
        let (service, viewModel) = await openedConversation()
        await service.emit("message", FakeChatService.message(id: "a1", role: "assistant", text: "Hai"))
        await waitUntil { viewModel.messages.count == 1 }
        await service.emit("heartbeat")
        await service.emit("message", FakeChatService.message(id: "a1", role: "assistant", text: "Hai"))
        await service.emit("unknown")
        await service.emit("message", FakeChatService.message(id: "a2", role: "assistant", text: "Lagi", minute: 1))
        await waitUntil { viewModel.messages.count == 2 }
        #expect(viewModel.messages.map(\.id) == ["a1", "a2"])
    }

    @Test
    func droppedStreamReconnectsOnceThenFailsAndRetryRecovers() async {
        let (service, viewModel) = await openedConversation()
        await service.setLatestPage(
            FakeChatService.page(
                [FakeChatService.json(id: "missed", role: "assistant", text: "Terlewat")], isMoreAvailable: false))
        await service.drop()
        await waitUntil { await service.startCount == 2 }
        await waitUntil { viewModel.phase == .ready && viewModel.messages.map(\.id) == ["missed"] }
        await waitUntil { await service.openedStreams == 2 }
        // Putus lagi tanpa event apa pun: tidak reconnect kedua kalinya.
        await service.drop()
        await waitUntil { viewModel.phase == .failed }
        let startCount = await service.startCount
        #expect(startCount == 2)
        viewModel.retry()
        await waitUntil { viewModel.phase == .ready }
        #expect(viewModel.messages.map(\.id) == ["missed"])
    }

    @Test
    func startFailureShowsFailedStateAndRetryRecovers() async {
        let service = FakeChatService()
        await service.setStartFailing(true)
        let viewModel = ChatViewModel(service: service)
        viewModel.start()
        await waitUntil { viewModel.phase == .failed }
        #expect(!viewModel.send("Halo"))
        await service.setStartFailing(false)
        viewModel.retry()
        await waitUntil { viewModel.phase == .ready }
    }

    @Test
    func failedSendStaysVisibleAndCanBeResent() async {
        let (service, viewModel) = await openedConversation()
        await service.setSendFailing(true)
        #expect(viewModel.send("Transfer"))
        await waitUntil { viewModel.messages.last?.delivery == .failed }
        #expect(!viewModel.isReplying)
        await service.setSendFailing(false)
        viewModel.resend(viewModel.messages.last?.id ?? "")
        await waitUntil { viewModel.messages.last?.delivery == .sent }
        let sent = await service.sentTexts
        #expect(sent == ["Transfer", "Transfer"])
    }

    @Test
    func olderHistoryIsAddedAboveUntilThereIsNoMore() async {
        let service = FakeChatService()
        await service.setLatestPage(
            FakeChatService.page(
                [FakeChatService.json(id: "m3", role: "user", text: "Baru", minute: 3)], isMoreAvailable: true)
        )
        await service.setPage(
            FakeChatService.page(
                [FakeChatService.json(id: "m1", role: "user", text: "Lama", minute: 1)], isMoreAvailable: false),
            before: "m3")
        let viewModel = ChatViewModel(service: service)
        viewModel.start()
        await waitUntil { viewModel.phase == .ready }
        viewModel.loadOlder()
        viewModel.loadOlder()
        await waitUntil { viewModel.messages.map(\.id) == ["m1", "m3"] }
        #expect(!viewModel.isMoreHistoryAvailable)
        viewModel.loadOlder()
        let cursors = await service.historyCursors
        #expect(cursors == [nil, "m3"])
    }

    @Test
    func answerArrivingBeforeTheSendConfirmationIsNotLeftWaiting() {
        let viewModel = ChatViewModel(service: FakeChatService())
        viewModel.phase = .ready
        viewModel.messages = [ChatMessage.pendingQuestion("Halo")]
        let pendingId = viewModel.messages[0].id
        viewModel.merge([
            ChatMessage(id: "a1", role: .assistant, text: "Hai", createdAt: Date(), replyTo: "user-1")
        ])
        viewModel.didDeliver(
            pendingId: pendingId,
            stored: ChatMessage(id: "user-1", role: .user, text: "Halo", createdAt: Date(), replyTo: nil))
        #expect(!viewModel.isReplying)
    }
}

// MARK: - Helpers

private extension ChatViewModelTests {
    func openedConversation() async -> (FakeChatService, ChatViewModel) {
        let service = FakeChatService()
        let viewModel = ChatViewModel(service: service)
        viewModel.start()
        await waitUntil { viewModel.phase == .ready }
        await waitUntil { await service.openedStreams == 1 }
        return (service, viewModel)
    }
}
