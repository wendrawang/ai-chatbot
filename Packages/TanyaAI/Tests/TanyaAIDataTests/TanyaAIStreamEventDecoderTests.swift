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
        XCTAssertEqual(message, "This content requires a newer app version.")
    }

    func testUnknownNonContentEventIsIgnored() throws {
        XCTAssertNil(
            try decoder.decode(name: "telemetry.sample", json: json([:]))
        )
    }

    func testUnknownVisualValuesUseAllowlistedDefaults() throws {
        let chartResult = try decoder.decode(
            name: "content.chart",
            json: json(chartPayload(type: "three-dimensional"))
        )
        let statusResult = try decoder.decode(
            name: "content.status",
            json: json(statusPayload(level: "critical"))
        )

        guard case .content(_, .chart(let chart)) = chartResult,
              case .content(_, .status(let status)) = statusResult else {
            return XCTFail("Expected typed content")
        }
        XCTAssertEqual(chart.chartType, .bar)
        XCTAssertEqual(status.level, .neutral)
    }

    func testMalformedKnownEventThrows() {
        XCTAssertThrowsError(
            try decoder.decode(
                name: "content.chart",
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

    private func chartPayload(type: String) -> [String: Any] {
        [
            "messageIdentifier": "chart-message",
            "title": "Sample chart",
            "chartType": type,
            "series": [
                [
                    "label": "Sample",
                    "value": 1.0,
                    "formattedValue": "1"
                ]
            ]
        ]
    }

    private func statusPayload(level: String) -> [String: Any] {
        [
            "messageIdentifier": "status-message",
            "title": "Sample status",
            "detail": "Sanitized detail",
            "level": level
        ]
    }
}
