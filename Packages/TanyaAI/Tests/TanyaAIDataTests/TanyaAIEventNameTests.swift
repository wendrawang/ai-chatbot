import Foundation
import TanyaAIContracts
import TanyaAIDomain
import XCTest

@testable import TanyaAIData

final class TanyaAIEventNameTests: XCTestCase {
    func testCanonicalNamesAreCompleteUniqueAndDotFree() {
        let expected: Set<String> = ["response", "response_started", "text_delta", "response_completed", "heartbeat"]
        let names = TanyaAIEventName.allCases.map(\.rawValue)
        XCTAssertEqual(Set(names), expected)
        XCTAssertEqual(names.count, expected.count)
        XCTAssertTrue(names.allSatisfy { !$0.contains(".") })
    }

    func testEveryCanonicalNameDecodes() throws {
        let decoder = TanyaAIStreamEventDecoder()
        for name in TanyaAIEventName.allCases {
            let event = try XCTUnwrap(decoder.decode(name: name.rawValue, json: payload()))
            guard name.isContent else { continue }
            guard case .content(_, let content) = event else {
                return XCTFail("Expected content for \(name.rawValue)")
            }
            if case .unsupported = content { XCTFail("Unsupported: \(name.rawValue)") }
        }
    }

    func testLegacyNamesStillResolveToTheSameCanonicalTypes() {
        for name in TanyaAIEventName.allCases where name.isContent {
            let legacy = "content." + name.rawValue.replacingOccurrences(of: "_", with: "-")
            XCTAssertEqual(TanyaAIEventName(wireName: legacy), name)
        }
        XCTAssertEqual(TanyaAIEventName(wireName: "response.started"), .responseStarted)
        XCTAssertEqual(TanyaAIEventName(wireName: "text.delta"), .textDelta)
        XCTAssertEqual(TanyaAIEventName(wireName: "response.completed"), .responseCompleted)
    }

    func testWireLifecycleUsesNativeSessionEvents() throws {
        guard
            case .messageStarted(let started) = try TanyaAIChatSessionEvent.fromWire(
                name: "response_started", json: payload()
            )
        else { return XCTFail("Missing native start") }
        guard
            case .messageDelta(let identifier, let text) = try TanyaAIChatSessionEvent.fromWire(
                name: "text_delta", json: payload()
            )
        else { return XCTFail("Missing native delta") }
        guard
            case .messageCompleted(let completed) = try TanyaAIChatSessionEvent.fromWire(
                name: "response_completed", json: payload()
            )
        else { return XCTFail("Missing native completion") }
        XCTAssertEqual(started, "sample")
        XCTAssertEqual(identifier, started)
        XCTAssertEqual(completed, started)
        XCTAssertEqual(text, "Sample text")
    }

    func testWireCanonicalizesStructuredPayloadWithoutChangingJSON() throws {
        let json = try payload()
        guard
            case .structuredPayload(let name, let data) = try TanyaAIChatSessionEvent.fromWire(
                name: "content.response", json: json
            )
        else { return XCTFail("Missing structured payload") }
        XCTAssertEqual(name, "response")
        XCTAssertEqual(data, json)
    }

    func testLifecycleIsNotClassifiedAsContent() {
        for name in TanyaAIEventName.allCases {
            XCTAssertEqual(TanyaAIEventName.isContentName(name.rawValue), name.isContent)
        }
        XCTAssertTrue(TanyaAIEventName.isContentName("future_card"))
        XCTAssertFalse(TanyaAIEventName.isContentName(""))
        XCTAssertFalse(TanyaAIEventName.isContentName("telemetry.changed"))
    }

    func testUnknownFlatNameShowsFallback() throws {
        let decoder = TanyaAIStreamEventDecoder()
        guard
            case .content(let identifier, .unsupported(let text)) = try decoder.decode(
                name: "future_card", json: payload()
            )
        else { return XCTFail("Missing fallback") }
        XCTAssertEqual(identifier, "sample")
        XCTAssertEqual(text, "Please update")
        XCTAssertNil(try decoder.decode(name: "telemetry.changed", json: payload()))
    }

    func testInvalidLifecyclePayloadThrows() {
        for name in ["response_started", "text_delta", "response_completed"] {
            XCTAssertThrowsError(try TanyaAIChatSessionEvent.fromWire(name: name, json: Data("{}".utf8)))
        }
    }

    private func payload() throws -> Data {
        let object: [String: Any] = [
            "messageIdentifier": "sample", "text": "Sample text",
            "response": ["blocks": [["type": "text", "text": "Sample text"]]],
            "fallbackText": "Please update"
        ]
        return try JSONSerialization.data(withJSONObject: object)
    }
}
