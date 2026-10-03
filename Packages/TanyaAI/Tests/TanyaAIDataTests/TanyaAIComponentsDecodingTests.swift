import Foundation
import TanyaAIContracts
import TanyaAIDomain
import XCTest
@testable import TanyaAIData

final class TanyaAIComponentsDecodingTests: XCTestCase {
    func testTextElementStaysPlainText() throws {
        XCTAssertEqual(try content([.text("Ada promo?")]), .text("Ada promo?"))
    }

    func testAllFourPartsShareOneStableMessageAndPreserveUnicode() throws {
        let elements = try [radio, info, link].map(custom)
        guard case .answer(let answer) = try content([.text("Promo 🎉")] + elements) else {
            return XCTFail("Missing composite answer")
        }
        XCTAssertEqual(answer.text, "Promo 🎉")
        XCTAssertEqual(answer.options.first?.identifier, "promo_cashback10")
        XCTAssertEqual(answer.options.first?.title, "Cashback Belanja 10%")
        XCTAssertEqual(answer.options.first?.prompt, "Cashback Belanja 10%")
        XCTAssertEqual(answer.image?.title, "Cashback Belanja 10%")
        XCTAssertEqual(answer.image?.caption, "Berlaku sampai akhir tahun")
        XCTAssertEqual(answer.actions?.buttons.first?.action.destinationType, .deeplink)
    }

    func testAllNonemptyCombinationsOfFourPartsDecode() throws {
        let parts = try [TanyaAIChatSessionElement.text("Promo"), custom(radio), custom(info), custom(link)]
        for mask in 1..<16 {
            let selected = parts.indices.filter { mask & (1 << $0) != 0 }.map { parts[$0] }
            let decoded = try content(selected)
            if mask == 1 { XCTAssertEqual(decoded, .text("Promo")); continue }
            guard case .answer(let answer) = decoded else { return XCTFail("Missing answer for \(mask)") }
            XCTAssertEqual(answer.text != nil, mask & 1 != 0)
            XCTAssertEqual(!answer.options.isEmpty, mask & 2 != 0)
            XCTAssertEqual(answer.image != nil, mask & 4 != 0)
            XCTAssertEqual(answer.actions != nil, mask & 8 != 0)
        }
    }

    func testAllDestinationTypesArePreservedAndUnknownTypeIsRejected() throws {
        for type in ["deeplink", "webview", "browser"] {
            var object = link
            object["destination_type"] = type
            guard case .answer(let answer) = try content([custom(object)]) else { return XCTFail("Missing link") }
            XCTAssertEqual(answer.actions?.buttons.first?.action.destinationType.rawValue, type)
        }
        var unknown = link
        unknown["destination_type"] = "execute"
        XCTAssertThrowsError(try content([custom(unknown)]))
    }

    func testConfirmationKeepsReferenceAndExactRawAmountWithoutInventedAuthorization() throws {
        let object: [String: Any] = [
            "type": "confirmation_card", "confirmation_id": "conf_7c2ab9",
            "fields": [
                ["key": "from", "label": "Dari", "value": "Tabungan · 6210"],
                ["key": "amount", "label": "Jumlah", "value": "Rp2.000.000", "raw_value": 2_000_000]
            ]
        ]
        guard case .confirmation(let card) = try content([custom(object)]) else { return XCTFail("Missing card") }
        XCTAssertEqual(card.confirmationIdentifier, "conf_7c2ab9")
        XCTAssertEqual(card.fields.last?.rawValue, Decimal(2_000_000))
        XCTAssertNil(card.fields.first?.rawValue)
        XCTAssertThrowsError(try content([.text("Wrong composition"), custom(object)]))
    }

    func testMalformedUnknownAndDuplicateOptionsCannotBecomeRawJSONText() throws {
        XCTAssertThrowsError(try content([.custom(Data("not JSON".utf8))]))
        XCTAssertThrowsError(try content([custom(["type": "unknown_card"])]))
        XCTAssertThrowsError(try content([custom(["type": "radio_button", "options": "wrong"])]))
        let duplicate = ["type": "radio_button", "options": [
            ["label": "First", "value": "same"], ["label": "Second", "value": "same"]
        ]] as [String: Any]
        XCTAssertThrowsError(try content([custom(duplicate)]))
    }

    func testHistoryAndLiveUseIdenticalStructuredPayloadAndCompleteOnlyOnce() throws {
        let message = try TanyaAIChatSessionMessage(identifier: "stable", author: .assistant, elements: [custom(radio)])
        guard case .structuredPayload(let name, let json) = message.contentEvents.first else {
            return XCTFail("Missing live payload")
        }
        XCTAssertEqual(name, message.structuredName)
        XCTAssertEqual(json, message.structuredJSON)
        XCTAssertEqual(message.contentEvents.count, 2)
        guard case .messageCompleted("stable") = message.contentEvents.last else {
            return XCTFail("Missing completion")
        }
    }

    private func content(_ elements: [TanyaAIChatSessionElement]) throws -> TanyaAIMessageContent {
        let message = try TanyaAIChatSessionMessage(identifier: "stable", author: .assistant, elements: elements)
        let json = try XCTUnwrap(message.structuredJSON)
        guard case .content("stable", let content) = try TanyaAIStreamEventDecoder().decode(
            name: "components", json: json
        ) else { throw NSError(domain: "Missing content", code: 1) }
        return content
    }

    private func custom(_ object: [String: Any]) throws -> TanyaAIChatSessionElement {
        .custom(try JSONSerialization.data(withJSONObject: object))
    }

    private var radio: [String: Any] {
        ["type": "radio_button", "options": [["label": "Cashback Belanja 10%", "value": "promo_cashback10"]]]
    }

    private var info: [String: Any] {
        ["type": "info_card", "title": "Cashback Belanja 10%", "description": "Berlaku sampai akhir tahun",
         "image": "https://example.com/promo.jpg"]
    }

    private var link: [String: Any] {
        ["type": "link_button", "label": "Bicara dengan Agent", "target": "ocbcid://mobile?type=live-chat",
         "destination_type": "deeplink"]
    }
}
