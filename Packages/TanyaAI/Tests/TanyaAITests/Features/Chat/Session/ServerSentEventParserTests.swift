//
//  ServerSentEventParserTests.swift
//  TanyaAI
//
//  Created by Wendra on 28/10/26.
//

import Testing

@testable import TanyaAI

/// Frame grammar contract: `id:`, `event:`, `data:` lalu baris kosong; komentar `:` untuk connected/keepalive.
struct ServerSentEventParserTests {
    @Test
    func blankLineClosesTheFrameAndCommentsAreIgnored() {
        let events = parse([": connected", "id: 1", "event: turn_end", "data: {}", "", ": keepalive"])
        #expect(events == [ServerSentEvent(id: "1", name: "turn_end", data: "{}")])
    }

    /// `URLSession.AsyncBytes.lines` membuang baris kosong; frame tetap terpisah di baris `id:` berikutnya.
    @Test
    func framesWithoutBlankLinesSplitAtTheNextIdAndTheLastOneFlushes() {
        var parser = ServerSentEventParser()
        let lines = ["id: 1", "event: message", "data: {\"a\":1}", "id: 2", "event: turn_end", "data: {}"]
        let events = lines.compactMap { parser.consume($0) } + [parser.flush()].compactMap { $0 }
        #expect(events.map(\.id) == ["1", "2"])
        #expect(events.map(\.name) == ["message", "turn_end"])
    }

    @Test
    func missingEventLineDefaultsToMessageAndOnlyOneLeadingSpaceIsStripped() {
        let events = parse(["data:  spasi", ""])
        #expect(events == [ServerSentEvent(id: nil, name: "message", data: " spasi")])
    }

    @Test
    func carriageReturnsAreTrimmedAndBlankLinesWithoutDataEmitNothing() {
        #expect(parse(["", "", "id: 3\r", "data: x\r", "\r"]) == [ServerSentEvent(id: "3", name: "message", data: "x")])
    }
}

// MARK: - Helpers

private extension ServerSentEventParserTests {
    func parse(_ lines: [String]) -> [ServerSentEvent] {
        var parser = ServerSentEventParser()
        return lines.compactMap { parser.consume($0) }
    }
}
