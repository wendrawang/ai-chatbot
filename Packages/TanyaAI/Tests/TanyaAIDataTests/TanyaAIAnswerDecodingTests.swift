import DesignKit
import Foundation
import TanyaAIDomain
import XCTest
@testable import TanyaAIData

final class TanyaAIAnswerDecodingTests: XCTestCase {
    func testEveryNonemptyCombinationDecodes() throws {
        let parts: [(String, Any)] = [
            ("text", "Choose a service"),
            ("options", [["identifier": "help", "title": "Help"]]),
            ("image", ["imageURL": "https://example.com/promo.png"]),
            ("actions", [["title": "Open", "action": ["identifier": "open", "deeplink": "host://open"]]])
        ]
        for combination in 1..<16 {
            var object: [String: Any] = ["messageIdentifier": "reply"]
            for index in parts.indices where combination & (1 << index) != 0 {
                object[parts[index].0] = parts[index].1
            }
            let answer = try decode(object)
            XCTAssertEqual(answer.text != nil, combination & 1 != 0)
            XCTAssertEqual(!answer.options.isEmpty, combination & 2 != 0)
            XCTAssertEqual(answer.image != nil, combination & 4 != 0)
            XCTAssertEqual(answer.actions != nil, combination & 8 != 0)
        }
    }

    func testOptionsDefaultTheirPromptToTheirTitle() throws {
        let answer = try decode([
            "messageIdentifier": "reply",
            "options": [["identifier": "help", "title": "Help"]]
        ])
        XCTAssertEqual(answer.options.first?.prompt, "Help")
        XCTAssertFalse(answer.isAnswered)
    }

    func testRestoredAnswerCarriesConsumedStateAndExplicitPrompt() throws {
        let answer = try decode([
            "messageIdentifier": "reply", "isAnswered": true,
            "options": [["identifier": "help", "title": "Help", "prompt": "Contact support"]]
        ])
        XCTAssertTrue(answer.isAnswered)
        XCTAssertEqual(answer.options.first?.prompt, "Contact support")
    }

    func testMissingContentShowsFallbackAndMalformedOptionsThrow() throws {
        let decoder = TanyaAIStreamEventDecoder()
        let empty = try JSONSerialization.data(withJSONObject: ["messageIdentifier": "empty"])
        guard case .content("empty", .unsupported(nil)) = try decoder.decode(name: "answer", json: empty) else {
            return XCTFail("An empty answer must not become a blank row")
        }
        let malformed = try JSONSerialization.data(withJSONObject: ["messageIdentifier": "bad", "options": "bad"])
        XCTAssertThrowsError(try decoder.decode(name: "answer", json: malformed))
    }

    func testChoicesWithoutMultipleSelectionUseRadioBehavior() throws {
        let json = try JSONSerialization.data(withJSONObject: [
            "messageIdentifier": "radio", "choices": [["identifier": "help", "title": "Help"]]
        ])
        guard case .content(_, .choices(let choices)) = try TanyaAIStreamEventDecoder().decode(
            name: "choices", json: json
        ) else { return XCTFail("Missing radio choices") }
        XCTAssertFalse(choices.isMultipleSelectionAllowed)
    }

    private func decode(_ object: [String: Any]) throws -> AnswerPayload {
        let json = try JSONSerialization.data(withJSONObject: object)
        guard case .content("reply", .answer(let answer)) = try TanyaAIStreamEventDecoder().decode(
            name: "answer", json: json
        ) else { throw NSError(domain: "Missing answer", code: 1) }
        return answer
    }
}
