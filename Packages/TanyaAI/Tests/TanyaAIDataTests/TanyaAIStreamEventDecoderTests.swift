import Foundation
import TanyaAIDomain
import XCTest

@testable import TanyaAIData

final class TanyaAIStreamEventDecoderTests: XCTestCase {
    private let decoder = TanyaAIStreamEventDecoder()

    func testUnknownContentUsesSafeFallback() throws {
        let result = try decoder.decode(
            name: "content.future-card",
            json: json([
                "messageIdentifier": "future-message",
                "fallbackText": "Update the app to view this card."
            ])
        )

        guard case .content(let identifier, .unsupported(let message)) = result else {
            return XCTFail("Expected unsupported content")
        }
        XCTAssertEqual(identifier, "future-message")
        XCTAssertEqual(message, "Update the app to view this card.")
    }

    func testUnknownContentUsesDefaultFallbackText() throws {
        let result = try decoder.decode(
            name: "content.future-card",
            json: json(["messageIdentifier": "future-message"])
        )

        guard case .content(_, .unsupported(let message)) = result else {
            return XCTFail("Expected unsupported content")
        }
        XCTAssertNil(message)
    }

    func testUnknownNonContentEventIsIgnored() throws {
        XCTAssertNil(
            try decoder.decode(name: "telemetry.sample", json: json([:]))
        )
    }

    func testMalformedKnownEventThrows() {
        XCTAssertThrowsError(
            try decoder.decode(
                name: "response",
                json: Data("not-json".utf8)
            )
        )
    }

    private func json(_ payload: [String: Any]) -> Data {
        (try? JSONSerialization.data(
            withJSONObject: payload,
            options: [.sortedKeys]
        )) ?? Data()
    }

}
