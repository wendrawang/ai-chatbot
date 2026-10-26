//
//  ChatViewModelTests.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

import Foundation
import Testing

@testable import TanyaAI

/// Sesi, history, config, stream dan reconnect.
@MainActor
struct ChatViewModelTests {
    @Test
    func emptyHistoryLoadsConfigBeforeTheStreamOpens() async {
        let service = FakeChatService()
        let shortcuts = #"[{"id":"s1","label":"Cek saldo"},{"id":"s2","label":"Promo","message":"Ada promo apa?"}]"#
        await service.setConfig(Data(#"{"greeting":"Hai!","shortcuts":\#(shortcuts)}"#.utf8))
        let viewModel = ChatViewModel(service: service)
        viewModel.start()
        viewModel.start()
        await waitUntil { viewModel.phase == .ready }
        await waitUntil { await service.openedStreams == 1 }
        let startCount = await service.startCount
        let configCount = await service.configCount
        #expect(startCount == 1)
        #expect(configCount == 1)
        #expect(viewModel.welcome?.greeting == "Hai!")
        #expect(viewModel.welcome?.shortcuts.map(\.message) == ["Cek saldo", "Ada promo apa?"])
        #expect(viewModel.isShortcutEnabled)
    }

    @Test
    func existingHistorySkipsConfig() async {
        let service = FakeChatService()
        await service.setLatestPage(
            FakeChatService.page(
                [
                    FakeChatService.json(id: "m1", role: "user", text: "Halo", minute: 1),
                    FakeChatService.json(id: "m2", role: "assistant", text: "Hai", replyTo: "m1", minute: 2)
                ], isMoreAvailable: true))
        let viewModel = await openedConversation(service)
        let configCount = await service.configCount
        let cursors = await service.historyCursors
        #expect(configCount == 0)
        #expect(viewModel.welcome == nil)
        #expect(cursors == [nil])
        #expect(viewModel.messages.map(\.id) == ["m1", "m2"])
        #expect(viewModel.isMoreHistoryAvailable)
    }

    @Test
    func heartbeatAndRepeatedMessagesLeaveTheListUnchanged() async {
        let service = FakeChatService()
        let viewModel = await openedConversation(service)
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
        let service = FakeChatService()
        let viewModel = await openedConversation(service)
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
    func reconnectFindsAnAnswerMissedWhileDisconnected() async {
        let service = FakeChatService()
        let viewModel = await openedConversation(service)
        await ask("Saldo?", as: "q1", in: viewModel, service: service)
        await service.setLatestPage(
            FakeChatService.page(
                [
                    FakeChatService.json(id: "q1", role: "user", text: "Saldo?"),
                    FakeChatService.json(id: "a1", role: "assistant", text: "Rp1", replyTo: "q1", minute: 1)
                ], isMoreAvailable: false))
        await service.drop()
        await waitUntil { viewModel.messages.map(\.id) == ["q1", "a1"] }
        #expect(viewModel.turn == .idle)
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
        let viewModel = await openedConversation(service)
        viewModel.loadOlder()
        viewModel.loadOlder()
        await waitUntil { viewModel.messages.map(\.id) == ["m1", "m3"] }
        #expect(!viewModel.isMoreHistoryAvailable)
        viewModel.loadOlder()
        let cursors = await service.historyCursors
        #expect(cursors == [nil, "m3"])
    }
}
