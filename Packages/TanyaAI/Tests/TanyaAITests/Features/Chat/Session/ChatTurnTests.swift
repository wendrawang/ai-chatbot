//
//  ChatTurnTests.swift
//  TanyaAI
//
//  Created by Wendra on 29/10/26.
//

import Testing

@testable import TanyaAI

/// Hanya `turn_end` setelah seq pertanyaan yang ditunggu yang membuka kunci.
struct ChatTurnTests {
    @Test
    func oldTurnEndFromReplayKeepsWaiting() {
        var turn = ChatTurn()
        turn.start()
        turn.accept(questionSeq: 10)
        turn.end(seq: 6)
        #expect(turn.isAwaiting)
        turn.end(seq: 12)
        #expect(!turn.isAwaiting)
    }

    @Test
    func turnEndBeforeTheAckIsMatchedWhenTheAckArrives() {
        var turn = ChatTurn()
        turn.start()
        turn.end(seq: 12)
        #expect(turn.isAwaiting)
        turn.accept(questionSeq: 10)
        #expect(!turn.isAwaiting)
    }

    @Test
    func oldTurnEndBeforeTheAckDoesNotUnlock() {
        var turn = ChatTurn()
        turn.start()
        turn.end(seq: 6)
        turn.accept(questionSeq: 10)
        #expect(turn.isAwaiting)
    }

    @Test
    func turnEndWithoutIdOrUnreadableAckStillUnlocks() {
        var withoutID = ChatTurn()
        withoutID.start()
        withoutID.accept(questionSeq: 10)
        withoutID.end(seq: nil)
        #expect(!withoutID.isAwaiting)
        var unreadableAck = ChatTurn()
        unreadableAck.start()
        unreadableAck.accept(questionSeq: nil)
        unreadableAck.end(seq: 3)
        #expect(!unreadableAck.isAwaiting)
    }

    @Test
    func turnEndWhileIdleChangesNothing() {
        var turn = ChatTurn()
        turn.end(seq: 4)
        #expect(turn == ChatTurn())
    }
}
