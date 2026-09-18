import DesignKit
import Foundation
import TanyaAIDomain
import XCTest
@testable import TanyaAIData

/// Decoding `content.image` - the promo card.
final class TanyaAIImageDecodingTests: XCTestCase {
    private let decoder = TanyaAIStreamEventDecoder()

    func testImageCardCarriesItsURLCaptionAndRatio() throws {
        let result = try decoder.decode(
            name: "content.image",
            json: json([
                "messageIdentifier": "img-1",
                "imageURL": "https://example.com/promo.png",
                "caption": "Bonus Bunga Tabungan hingga 5,25% p.a.",
                "aspectRatio": 1.6,
                "accessibilityText": "Amplop merah berisi koin"
            ])
        )

        guard case .content(let identifier, .image(let payload)) = result else {
            return XCTFail("Expected an image card")
        }
        XCTAssertEqual(identifier, "img-1")
        XCTAssertEqual(
            payload.imageURL,
            URL(string: "https://example.com/promo.png")
        )
        XCTAssertEqual(
            payload.caption,
            "Bonus Bunga Tabungan hingga 5,25% p.a."
        )
        XCTAssertEqual(payload.aspectRatio, 1.6)
        XCTAssertEqual(payload.accessibilityText, "Amplop merah berisi koin")
    }

    /// A backend that says nothing about the shape still gets a row whose
    /// height is known before the download lands.
    func testMissingRatioFallsBackToTheDefault() throws {
        let payload = try decodeImage(["aspectRatio": nil])

        XCTAssertEqual(
            payload.aspectRatio,
            ImagePayload.defaultAspectRatio
        )
    }

    /// Zero would collapse the row to nothing, and a negative ratio is not a
    /// shape at all. Both are treated as not having said.
    func testUnusableRatioFallsBackToTheDefault() throws {
        let zero = try decodeImage(["aspectRatio": 0])
        let negative = try decodeImage(["aspectRatio": -2])

        XCTAssertEqual(
            zero.aspectRatio,
            ImagePayload.defaultAspectRatio
        )
        XCTAssertEqual(
            negative.aspectRatio,
            ImagePayload.defaultAspectRatio
        )
    }

    /// The sentence is the message; the picture only illustrates it. A broken
    /// link loses the picture, not the bubble.
    func testUnusableURLKeepsTheCaption() throws {
        let payload = try decodeImage(["imageURL": ""])

        XCTAssertNil(payload.imageURL)
        XCTAssertEqual(payload.caption, "Promo tabungan")
    }

    private func decodeImage(
        _ overrides: [String: Any?]
    ) throws -> ImagePayload {
        var fields: [String: Any] = [
            "messageIdentifier": "img-1",
            "imageURL": "https://example.com/promo.png",
            "caption": "Promo tabungan"
        ]
        overrides.forEach { key, value in
            if let value = value {
                fields[key] = value
            } else {
                fields.removeValue(forKey: key)
            }
        }
        let result = try decoder.decode(
            name: "content.image",
            json: json(fields)
        )
        guard case .content(_, .image(let payload)) = result else {
            throw TanyaAIImageDecodingFailure.notAnImageCard
        }
        return payload
    }

    private func json(_ fields: [String: Any]) -> Data {
        // swiftlint:disable:next force_try
        try! JSONSerialization.data(withJSONObject: fields)
    }
}

private enum TanyaAIImageDecodingFailure: Error {
    case notAnImageCard
}
