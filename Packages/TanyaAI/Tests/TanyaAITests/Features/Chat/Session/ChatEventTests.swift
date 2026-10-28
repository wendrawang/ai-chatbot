//
//  ChatEventTests.swift
//  TanyaAI
//
//  Created by Wendra on 28/10/26.
//

import Testing

@testable import TanyaAI

/// Decode event dari contoh swagger (`j1-plain-bot-turn`); frame rusak atau belum dipakai diabaikan.
struct ChatEventTests {
    @Test
    func messageFrameDecodesTheFullMessageObject() {
        let event = ChatEvent(frame(WireFixture.messageFrame(seq: 2, direction: "bot")))
        let expected = ChatMessage(id: "m-2", seq: 2, author: .bot, text: "pesan 2", status: .active)
        #expect(event == .message(expected))
    }

    @Test
    func turnEndUnlocksRegardlessOfItsStatus() {
        #expect(ChatEvent(frame(WireFixture.turnEndFrame(seq: 3))) == .turnEnd)
    }

    @Test
    func canceledTombstoneKeepsItsStatus() {
        let event = ChatEvent(frame(WireFixture.messageFrame(seq: 1, status: "canceled")))
        #expect(
            event == .message(ChatMessage(id: "m-1", seq: 1, author: .customer, text: "pesan 1", status: .canceled)))
    }

    @Test
    func objectPayloadHasNoTextAndUnknownValuesDoNotFailTheFrame() {
        let data = #"{"message_id":"m-9","seq":"9","direction":"system","payload":{"k":1},"status":"new"}"#
        let event = ChatEvent(ServerSentEvent(id: "9", name: "message", data: data))
        #expect(event == .message(ChatMessage(id: "m-9", seq: 9, author: .unknown, text: nil, status: .unknown)))
    }

    @Test(arguments: [
        ServerSentEvent(id: "4", name: "message", data: "{rusak"),
        ServerSentEvent(
            id: "4", name: "message", data: #"{"message_id":"m","seq":"x","direction":"bot","status":"active"}"#),
        ServerSentEvent(id: "5", name: "typing", data: #"{"direction":"agent","typing":true,"ttl_s":10}"#),
        ServerSentEvent(id: "6", name: "state", data: #"{"from":"BOT_ACTIVE","to":"CLOSED","agent":null}"#)
    ])
    func brokenOrUnusedFramesAreIgnored(event: ServerSentEvent) {
        #expect(ChatEvent(event) == .ignored)
    }
}

// MARK: - Helpers

private extension ChatEventTests {
    func frame(_ lines: [String]) -> ServerSentEvent {
        var parser = ServerSentEventParser()
        return lines.compactMap { parser.consume($0) }[0]
    }
}
