//
//  ChatEventTests.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import XCTest

@testable import TanyaAI

final class ChatEventTests: XCTestCase {
    func testEventsDecodeFromSSEContract() {
        typealias Fake = FakeChatService
        XCTAssertEqual(ChatEvent(Fake.event("start", #"{"messageId":"m-1"}"#)), .start(messageId: "m-1"))
        XCTAssertEqual(ChatEvent(Fake.event("status", #"{"text":"Processing"}"#)), .status("Processing"))
        XCTAssertEqual(ChatEvent(Fake.event("delta", #"{"delta":"Saya [bold]wen"}"#)), .delta("Saya [bold]wen"))
        XCTAssertEqual(
            ChatEvent(
                Fake.event("intent", #"{"intent":{"name":"review-porto","inquiryId":"inq-1","parameters":{"a":"b"}}}"#)
            ),
            .intent(TanyaAIIntent(name: "review-porto", inquiryId: "inq-1", parameters: ["a": "b"]))
        )
        XCTAssertEqual(ChatEvent(Fake.event("end", "{}")), .end)
        XCTAssertEqual(ChatEvent(Fake.event("error", #"{"isRetryable":true}"#)), .failure(isRetryable: true))
        XCTAssertNil(ChatEvent(Fake.event("heartbeat", "{}")))
        XCTAssertNil(ChatEvent(Fake.event("delta", "bukan json")))
        XCTAssertNil(ChatEvent(Fake.event("status", "{}")))
    }

    func testBlocksDecodeEveryComponentAndSkipUnknownTypes() throws {
        let json = #"""
            {"blocks":[
              {"type":"text","text":"Halo"},
              {"type":"table","columns":[{"title":"Produk"},{"title":"Nilai","isTrailing":true}],
               "rows":[["Reksa Dana","35.000.000"]],"footer":{"label":"Total","value":"+3.600.000"}},
              {"type":"options","id":"product","items":[{"id":"p1","label":"Satu"}]},
              {"type":"media","imageUrl":null,"caption":"Promo","action":{"type":"link","value":"https://ocbc.id"}},
              {"type":"actions","items":[
                {"label":"Lanjut","style":"filled","action":{"type":"prompt","value":"Lanjut"}}
              ]},
              {"type":"suggestions","items":[{"label":"#1","action":{"type":"prompt","value":"#1"}}]},
              {"type":"carousel","items":[]}
            ]}
            """#
        guard case .blocks(let blocks) = try XCTUnwrap(ChatEvent(FakeChatService.event("blocks", json))) else {
            return XCTFail("Bukan event blocks")
        }
        XCTAssertEqual(blocks.count, 6)
        XCTAssertEqual(blocks.first, .text("Halo"))
        guard case .table(let table) = blocks[1] else { return XCTFail("Bukan tabel") }
        XCTAssertEqual(table.columns.map(\.isTrailing), [nil, true])
        XCTAssertEqual(table.footer?.value, "+3.600.000")
        guard case .actions(let actions) = blocks[4] else { return XCTFail("Bukan actions") }
        XCTAssertEqual(actions.first?.style, .filled)
        XCTAssertEqual(actions.first?.action.type, .prompt)
    }
}
