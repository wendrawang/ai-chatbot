//
//  ChatUserTypingTests.swift
//  TanyaAITests
//
//  Created by Wendra on 12/11/26.
//

import Testing

@testable import TanyaAI

/// Kapan sinyal mengetik nasabah perlu dikirim ke agen, dan nilai mana yang dikirim. Hasil setiap langkah disimpan
/// dulu karena `#expect` tidak bisa memanggil fungsi `mutating`.
struct ChatUserTypingTests {
    @Test
    func theFirstKeystrokeAnnouncesTyping() {
        var typing = ChatUserTyping()
        let isAnnouncing = typing.begin()
        let signals = [typing.takePending(isDeliverable: true), typing.takePending(isDeliverable: true)]
        #expect(isAnnouncing)
        #expect(signals == [true, nil])
    }

    @Test
    func keystrokesAreNotRepeatedUntilTheRefreshPasses() {
        var typing = ChatUserTyping()
        var announcements = [typing.begin(), typing.begin()]
        typing.expireFreshness()
        announcements.append(typing.begin())
        #expect(announcements == [true, false, true])
    }

    @Test
    func stoppingWithoutAnAnnouncementSendsNothing() {
        var typing = ChatUserTyping()
        let isStopping = typing.end()
        let signal = typing.takePending(isDeliverable: true)
        #expect(!isStopping)
        #expect(signal == nil)
    }

    @Test
    func stoppingAfterADeliveredAnnouncementSendsFalse() {
        var typing = ChatUserTyping()
        _ = typing.begin()
        let announced = typing.takePending(isDeliverable: true)
        let isStopping = typing.end()
        let stopped = typing.takePending(isDeliverable: true)
        #expect(announced == true)
        #expect(isStopping)
        #expect(stopped == false)
    }

    /// `true` belum sempat dikirim, jadi agen tidak pernah tahu dan `false` tidak diperlukan.
    @Test
    func stoppingBeforeTheAnnouncementWasDeliveredSendsNothing() {
        var typing = ChatUserTyping()
        _ = typing.begin()
        _ = typing.end()
        let signal = typing.takePending(isDeliverable: true)
        #expect(signal == nil)
    }

    @Test
    func waitingSignalsCollapseIntoTheLatest() {
        var typing = ChatUserTyping()
        _ = typing.begin()
        _ = typing.end()
        _ = typing.begin()
        let signals = [typing.takePending(isDeliverable: true), typing.takePending(isDeliverable: true)]
        #expect(signals == [true, nil])
    }

    /// Tidak lagi dengan agen: sinyal yang menunggu dibuang, bukan ditahan untuk nanti.
    @Test
    func aWaitingSignalIsDroppedOnceItCannotBeDelivered() {
        var typing = ChatUserTyping()
        _ = typing.begin()
        let signals = [typing.takePending(isDeliverable: false), typing.takePending(isDeliverable: true)]
        #expect(signals == [nil, nil])
    }

    @Test
    func resettingForgetsTheAnnouncement() {
        var typing = ChatUserTyping()
        _ = typing.begin()
        _ = typing.takePending(isDeliverable: true)
        typing.reset()
        #expect(typing == ChatUserTyping())
        let isStopping = typing.end()
        let isAnnouncing = typing.begin()
        #expect(!isStopping)
        #expect(isAnnouncing)
    }
}
