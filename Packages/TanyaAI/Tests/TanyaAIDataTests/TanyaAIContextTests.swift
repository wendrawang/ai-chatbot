import Foundation
import TanyaAIContracts
import TanyaAIDomain
import XCTest
@testable import TanyaAIData

/// The context is metadata, not chat content: it must reach the backend with
/// every message and never appear in the conversation.
final class TanyaAIContextTests: XCTestCase {
    func testContextIsAttachedToEveryRequestBody() throws {
        let transport = TransportSpy()
        let repository = DefaultTanyaAIRepository(
            transport: transport,
            messagePath: "/messages",
            context: TanyaAIContext(
                screen: "transfer.form",
                parameters: ["beneficiary": "Sample", "amount": "1250000"],
                summary: "About: transfer to Sample"
            )
        )

        repository.sendMessage(
            conversationIdentifier: "c1",
            text: "Berapa biayanya?",
            onEvent: { _ in },
            completion: { _ in }
        )

        let body = try XCTUnwrap(transport.lastBody)
        let payload = try XCTUnwrap(
            JSONSerialization.jsonObject(with: body) as? [String: Any]
        )
        XCTAssertEqual(payload["message"] as? String, "Berapa biayanya?")
        let context = try XCTUnwrap(payload["context"] as? [String: Any])
        XCTAssertEqual(context["screen"] as? String, "transfer.form")
        let parameters = try XCTUnwrap(
            context["parameters"] as? [String: String]
        )
        XCTAssertEqual(parameters["amount"], "1250000")
    }

    /// The summary exists for the customer, not for the bot. Sending it would
    /// leak a display string into stored conversation data for no gain.
    func testSummaryStaysOnTheDevice() throws {
        let context = TanyaAIContext(
            screen: "transfer.form",
            summary: "About: transfer to Sample"
        )

        let payload = context.payload

        XCTAssertNil(payload["summary"])
        XCTAssertNil(payload["parameters"])
        XCTAssertEqual(payload["screen"] as? String, "transfer.form")
    }

    func testClearedContextIsNoLongerSent() throws {
        let transport = TransportSpy()
        let repository = DefaultTanyaAIRepository(
            transport: transport,
            messagePath: "/messages",
            context: TanyaAIContext(screen: "transfer.form")
        )

        repository.updateContext(nil)
        repository.sendMessage(
            conversationIdentifier: nil,
            text: "Halo",
            onEvent: { _ in },
            completion: { _ in }
        )

        let body = try XCTUnwrap(transport.lastBody)
        let payload = try XCTUnwrap(
            JSONSerialization.jsonObject(with: body) as? [String: Any]
        )
        XCTAssertNil(payload["context"])
    }

    func testRequestWithoutContextKeepsTheOriginalBodyShape() throws {
        let transport = TransportSpy()
        let repository = DefaultTanyaAIRepository(
            transport: transport,
            messagePath: "/messages"
        )

        repository.sendMessage(
            conversationIdentifier: nil,
            text: "Halo",
            onEvent: { _ in },
            completion: { _ in }
        )

        let body = try XCTUnwrap(transport.lastBody)
        let payload = try XCTUnwrap(
            JSONSerialization.jsonObject(with: body) as? [String: Any]
        )
        XCTAssertEqual(payload.count, 1)
        XCTAssertEqual(payload["message"] as? String, "Halo")
    }
}

private final class TransportSpy: TanyaAIStreamingTransport {
    private(set) var lastBody: Data?

    @discardableResult
    func stream(
        _ request: TanyaAIStreamRequest,
        onData: @escaping (Data) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable {
        lastBody = request.body
        return TanyaAINoOpCancellable()
    }
}
