import Foundation
import TanyaAIDomain
import XCTest
@testable import TanyaAIData

final class TanyaAIStreamEventDecoderTests: XCTestCase {
    private let decoder = TanyaAIStreamEventDecoder()

    func testUnknownContentUsesSafeFallback() throws {
        let event = makeEvent(
            name: "content.future-card",
            payload: [
                "messageIdentifier": "future-message",
                "fallbackText": "Update the app to view this card."
            ]
        )

        let result = try decoder.decode(event)

        guard case .content(let identifier, .unsupported(let message)) = result else {
            return XCTFail("Expected unsupported content")
        }
        XCTAssertEqual(identifier, "future-message")
        XCTAssertEqual(message, "Update the app to view this card.")
    }

    func testUnknownContentUsesDefaultFallbackText() throws {
        let event = makeEvent(
            name: "content.future-card",
            payload: ["messageIdentifier": "future-message"]
        )

        let result = try decoder.decode(event)

        guard case .content(_, .unsupported(let message)) = result else {
            return XCTFail("Expected unsupported content")
        }
        XCTAssertEqual(message, "This content requires a newer app version.")
    }

    func testUnknownNonContentEventIsIgnored() throws {
        let event = makeEvent(name: "telemetry.sample", payload: [:])

        XCTAssertNil(try decoder.decode(event))
    }

    func testUnknownVisualValuesUseAllowlistedDefaults() throws {
        let chartResult = try decoder.decode(
            makeEvent(
                name: "content.chart",
                payload: chartPayload(type: "three-dimensional")
            )
        )
        let statusResult = try decoder.decode(
            makeEvent(
                name: "content.status",
                payload: statusPayload(level: "critical")
            )
        )

        guard case .content(_, .chart(let chart)) = chartResult,
              case .content(_, .status(let status)) = statusResult else {
            return XCTFail("Expected typed content")
        }
        XCTAssertEqual(chart.chartType, .bar)
        XCTAssertEqual(status.level, .neutral)
    }

    func testMalformedKnownEventThrows() {
        let event = TanyaAISSEEvent(
            name: "content.chart",
            data: Data("not-json".utf8)
        )

        XCTAssertThrowsError(try decoder.decode(event))
    }

    private func makeEvent(
        name: String,
        payload: [String: Any]
    ) -> TanyaAISSEEvent {
        let data = (try? JSONSerialization.data(
            withJSONObject: payload,
            options: [.sortedKeys]
        )) ?? Data()
        return TanyaAISSEEvent(name: name, data: data)
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
