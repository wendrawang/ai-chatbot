import Foundation
import TanyaAIDomain
import XCTest

@testable import TanyaAIData

final class TanyaAIResponseDecodingTests: XCTestCase {
    func testDecoderPreservesAlternatingTextTableAndActionOrder() throws {
        let event = try decode(blocks: [
            ["type": "text", "text": "Introduction"],
            [
                "type": "table",
                "table": [
                    "columns": [["title": "Product"], ["title": "Risk"]],
                    "rows": [["cells": ["Fund", "Low"]]]
                ]
            ],
            ["type": "text", "text": "Evaluation"],
            [
                "type": "actions",
                "actions": [
                    [
                        "identifier": "buy", "title": "Buy", "intent": "prompt", "target": "Buy product"
                    ]
                ]
            ]
        ])
        guard case .content("response", .response(let response)) = event else { return XCTFail("Missing response") }
        XCTAssertEqual(response.blocks.count, 4)
        XCTAssertEqual(response.blocks[0], .text("Introduction"))
        guard case .table(let table) = response.blocks[1] else { return XCTFail("Table order changed") }
        XCTAssertEqual(table.rows[0].cells, ["Fund", "Low"])
        XCTAssertEqual(response.blocks[2], .text("Evaluation"))
        guard case .actions(let actions) = response.blocks[3] else { return XCTFail("Action order changed") }
        XCTAssertEqual(actions.first?.target, "Buy product")
    }

    func testUnknownBlockAndEmptyResponseFailRatherThanBecomeBlankBubbles() {
        XCTAssertThrowsError(try decode(blocks: [["type": "unknown"]]))
        XCTAssertThrowsError(try decode(blocks: []))
    }

    func testResponseTableCannotExceedThreeColumnsOrDiscardCells() {
        let columns = ["A", "B", "C", "D"].map { ["title": $0] }
        XCTAssertThrowsError(try decode(blocks: [["type": "table", "table": ["columns": columns, "rows": []]]]))
        XCTAssertThrowsError(
            try decode(blocks: [
                [
                    "type": "table",
                    "table": [
                        "columns": [["title": "A"], ["title": "B"]], "rows": [["cells": ["Missing second"]]]
                    ]
                ]
            ]))
    }

    private func decode(blocks: [[String: Any]]) throws -> TanyaAIStreamEvent? {
        let object: [String: Any] = ["messageIdentifier": "response", "response": ["blocks": blocks]]
        return try TanyaAIStreamEventDecoder().decode(
            name: "response", json: JSONSerialization.data(withJSONObject: object)
        )
    }
}
