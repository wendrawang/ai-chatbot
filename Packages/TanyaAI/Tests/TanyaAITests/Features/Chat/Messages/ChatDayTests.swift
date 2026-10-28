//
//  ChatDayTests.swift
//  TanyaAI
//
//  Created by Wendra on 28/10/26.
//

import Foundation
import Testing

@testable import TanyaAI

/// Chip tanggal di atas pesan pertama setiap hari kalender (zona waktu perangkat).
struct ChatDayTests {
    @Test
    func wireDatesKeepTheirTimeZoneWithOrWithoutFractions() {
        #expect(Date(wire: WireFixture.createdAtText) == WireFixture.createdAt)
        #expect(Date(wire: "2026-10-23T08:00:00.250Z") == WireFixture.createdAt.addingTimeInterval(0.25))
        #expect(Date(wire: "23-10-2026") == nil)
    }

    @Test
    func messagesSplitWhereTheLocalDayChanges() throws {
        let calendar = try jakartaCalendar()
        let days = [
            message(1, "2026-10-14T09:00:00+07:00"), message(2, "2026-10-14T23:59:00+07:00"),
            message(3, "2026-10-15T00:01:00+07:00")
        ].groupedByDay(calendar: calendar)
        #expect(days.map { $0.messages.map(\.seq) } == [[1, 2], [3]])
        #expect(days.map(\.id) == ["m-1", "m-3"])
    }

    /// Hari mengikuti zona perangkat, bukan zona dari server: 23:30 WIB = keesokan hari di WITA.
    @Test
    func dayFollowsTheDeviceTimeZone() throws {
        var calendar = try jakartaCalendar()
        calendar.timeZone = try #require(TimeZone(identifier: "Asia/Makassar"))
        let days = [message(1, "2026-10-14T22:00:00+07:00"), message(2, "2026-10-14T23:30:00+07:00")]
            .groupedByDay(calendar: calendar)
        #expect(days.count == 2)
    }

    /// Buffer di-append, kelompok dibentuk sekali per hari (bukan menyalin kelompok setiap pesan).
    @Test
    func thousandsOfSameDayMessagesStayInOneGroupInOrder() throws {
        let calendar = try jakartaCalendar()
        let date = Date(wire: "2026-10-14T09:00:00+07:00")
        let messages = (1...5_000).map {
            ChatMessage(id: "m-\($0)", seq: $0, author: .bot, text: "pesan", status: .active, createdAt: date)
        }
        let days = messages.groupedByDay(calendar: calendar)
        #expect(days.count == 1)
        #expect(days.first?.messages.map(\.seq) == Array(1...5_000))
    }

    @Test
    func messageWithoutADateJoinsThePreviousDay() throws {
        let calendar = try jakartaCalendar()
        let days = [message(1, "2026-10-14T09:00:00+07:00"), message(2, nil)].groupedByDay(calendar: calendar)
        #expect(days.map { $0.messages.count } == [2])
        #expect([message(1, nil)].groupedByDay(calendar: calendar).first?.date == nil)
    }
}

// MARK: - Helpers

private extension ChatDayTests {
    func jakartaCalendar() throws -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "Asia/Jakarta"))
        return calendar
    }

    func message(_ seq: Int, _ createdAt: String?) -> ChatMessage {
        ChatMessage(
            id: "m-\(seq)", seq: seq, author: .bot, text: "pesan", status: .active,
            createdAt: createdAt.flatMap(Date.init(wire:))
        )
    }
}
