import DesignKit
import Foundation
import TanyaAIDomain
import XCTest
@testable import TanyaAIData

/// Decoding `content.html` - the static fragment.
final class TanyaAIHTMLDecodingTests: XCTestCase {
    private let decoder = TanyaAIStreamEventDecoder()

    func testFragmentCarriesItsHTMLHeightAndDescription() throws {
        let payload = try decodeHTML([
            "html": "<b>Halo</b>",
            "height": 140,
            "accessibilityText": "Sapaan"
        ])

        XCTAssertEqual(payload.html, "<b>Halo</b>")
        XCTAssertEqual(payload.declaredHeight, 140)
        XCTAssertEqual(payload.accessibilityText, "Sapaan")
    }

    /// A row still needs a height before anything renders, so one is assumed
    /// rather than left at zero.
    func testMissingHeightFallsBackToTheDefault() throws {
        let payload = try decodeHTML([:])

        XCTAssertNil(payload.declaredHeight)
        XCTAssertEqual(payload.initialHeight, HTMLPayload.defaultHeight)
    }

    /// Zero would collapse the bubble; a negative height is not a height.
    func testUnusableHeightIsTreatedAsUnsaid() throws {
        let zero = try decodeHTML(["height": 0])
        let negative = try decodeHTML(["height": -40])

        XCTAssertNil(zero.declaredHeight)
        XCTAssertNil(negative.declaredHeight)
        XCTAssertEqual(negative.initialHeight, HTMLPayload.defaultHeight)
    }

    private func decodeHTML(
        _ overrides: [String: Any]
    ) throws -> HTMLPayload {
        var fields: [String: Any] = [
            "messageIdentifier": "html-1",
            "html": "<p>x</p>"
        ]
        overrides.forEach { fields[$0.key] = $0.value }
        let result = try decoder.decode(
            name: "content.html",
            json: JSONSerialization.data(withJSONObject: fields)
        )
        guard case .content(_, .html(let payload)) = result else {
            throw TanyaAIHTMLDecodingFailure.notAnHTMLCard
        }
        return payload
    }
}

private enum TanyaAIHTMLDecodingFailure: Error {
    case notAnHTMLCard
}
