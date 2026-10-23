//
//  ChatViewModelTests.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

import XCTest

@testable import TanyaAI

@MainActor
final class ChatViewModelTests: XCTestCase {
    func testOpeningRunsStartThenHistoryThenKeepsTheStreamOpen() async {
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
        XCTAssertEqual(startCount, 1)
        XCTAssertEqual(cursors, [nil])
        XCTAssertEqual(viewModel.messages.map(\.id), ["m1", "m2"])
        XCTAssertTrue(viewModel.isMoreHistoryAvailable)
    }

    func testSendIsShownAtOnceThenConfirmedAndAnsweredThroughTheStream() async {
        let (service, viewModel) = await openedConversation()
        XCTAssertFalse(viewModel.send("   "))
        XCTAssertTrue(viewModel.send(" Saldo saya? "))
        XCTAssertEqual(viewModel.messages.last?.text, "Saldo saya?")
        XCTAssertEqual(viewModel.messages.last?.delivery, .sending)
        await waitUntil { viewModel.messages.last?.id == "user-1" }
        XCTAssertEqual(viewModel.messages.last?.delivery, .sent)
        XCTAssertTrue(viewModel.isReplying)
        await service.emit(
            "message", FakeChatService.message(id: "a1", role: "assistant", text: "Rp1", replyTo: "user-1"))
        await waitUntil { viewModel.messages.last?.id == "a1" }
        XCTAssertFalse(viewModel.isReplying)
    }

    func testHeartbeatAndRepeatedMessagesLeaveTheListUnchanged() async {
        let (service, viewModel) = await openedConversation()
        await service.emit("message", FakeChatService.message(id: "a1", role: "assistant", text: "Hai"))
        await waitUntil { viewModel.messages.count == 1 }
        await service.emit("heartbeat")
        await service.emit("message", FakeChatService.message(id: "a1", role: "assistant", text: "Hai"))
        await service.emit("unknown")
        await service.emit("message", FakeChatService.message(id: "a2", role: "assistant", text: "Lagi", minute: 1))
        await waitUntil { viewModel.messages.count == 2 }
        XCTAssertEqual(viewModel.messages.map(\.id), ["a1", "a2"])
    }

    func testDroppedStreamReconnectsOnceThenFailsAndRetryRecovers() async {
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
        XCTAssertEqual(startCount, 2)
        viewModel.retry()
        await waitUntil { viewModel.phase == .ready }
        XCTAssertEqual(viewModel.messages.map(\.id), ["missed"])
    }

    func testStartFailureShowsFailedStateAndRetryRecovers() async {
        let service = FakeChatService()
        await service.setStartFailing(true)
        let viewModel = ChatViewModel(service: service)
        viewModel.start()
        await waitUntil { viewModel.phase == .failed }
        XCTAssertFalse(viewModel.send("Halo"))
        await service.setStartFailing(false)
        viewModel.retry()
        await waitUntil { viewModel.phase == .ready }
    }

    func testFailedSendStaysVisibleAndCanBeResent() async {
        let (service, viewModel) = await openedConversation()
        await service.setSendFailing(true)
        XCTAssertTrue(viewModel.send("Transfer"))
        await waitUntil { viewModel.messages.last?.delivery == .failed }
        XCTAssertFalse(viewModel.isReplying)
        await service.setSendFailing(false)
        viewModel.resend(viewModel.messages.last?.id ?? "")
        await waitUntil { viewModel.messages.last?.delivery == .sent }
        let sent = await service.sentTexts
        XCTAssertEqual(sent, ["Transfer", "Transfer"])
    }

    func testOlderHistoryIsAddedAboveUntilThereIsNoMore() async {
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
        XCTAssertFalse(viewModel.isMoreHistoryAvailable)
        viewModel.loadOlder()
        let cursors = await service.historyCursors
        XCTAssertEqual(cursors, [nil, "m3"])
    }

    func testAnswerArrivingBeforeTheSendConfirmationIsNotLeftWaiting() {
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
        XCTAssertFalse(viewModel.isReplying)
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

    func waitUntil(timeout: TimeInterval = 3, _ condition: () async -> Bool) async {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if await condition() { return }
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
        XCTFail("Kondisi tidak terpenuhi dalam \(timeout) detik")
    }
}
