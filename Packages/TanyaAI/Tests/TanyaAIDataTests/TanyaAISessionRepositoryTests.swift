import Foundation
import TanyaAIContracts
import TanyaAIDomain
import XCTest
@testable import TanyaAIData

/// The session transport has to look identical to the SSE one from the
/// repository boundary upward, so these tests assert the mapping and the turn
/// bookkeeping rather than any vendor behaviour.
final class TanyaAISessionRepositoryTests: XCTestCase {
    func testTextRepliesMapToStreamEventsAndEndTheTurn() {
        let session = SessionSpy()
        let repository = TanyaAISessionRepository(session: session)
        var events: [TanyaAIStreamEvent] = []
        var completions: [Result<Void, Error>] = []

        repository.sendMessage(
            conversationIdentifier: nil,
            text: "Halo",
            onEvent: { events.append($0) },
            completion: { completions.append($0) }
        )
        session.emit(.messageStarted(messageIdentifier: "m1"))
        session.emit(.messageDelta(messageIdentifier: "m1", text: "Hai"))
        session.emit(.messageCompleted(messageIdentifier: "m1"))

        XCTAssertTrue(session.isConnected)
        XCTAssertEqual(session.sentTexts, ["Halo"])
        XCTAssertEqual(events.count, 3)
        XCTAssertEqual(completions.count, 1)
        guard case .success = completions[0] else {
            return XCTFail("Expected the turn to succeed")
        }
    }

    func testStructuredPayloadRendersTheSameTypedCardAsSSE() {
        let session = SessionSpy()
        let repository = TanyaAISessionRepository(session: session)
        var events: [TanyaAIStreamEvent] = []

        repository.sendMessage(
            conversationIdentifier: nil,
            text: "Transfer",
            onEvent: { events.append($0) },
            completion: { _ in }
        )
        session.emit(
            .structuredPayload(name: "content.actions", json: actionCardJSON)
        )

        let buttons = events.compactMap { event -> [TanyaAIActionButton]? in
            guard case .content(_, .actions(let payload)) = event else {
                return nil
            }
            return payload.buttons
        }.flatMap { $0 }
        XCTAssertEqual(buttons.count, 1)
        XCTAssertEqual(
            buttons.first?.action.deeplink,
            "ocbcid://mobile?type=transfer"
        )
    }

    func testMalformedPayloadDegradesInsteadOfFailingTheTurn() {
        let session = SessionSpy()
        let repository = TanyaAISessionRepository(session: session)
        var events: [TanyaAIStreamEvent] = []
        var completions: [Result<Void, Error>] = []

        repository.sendMessage(
            conversationIdentifier: nil,
            text: "Transfer",
            onEvent: { events.append($0) },
            completion: { completions.append($0) }
        )
        session.emit(
            .structuredPayload(
                name: "content.approval",
                json: Data("{\"broken\":true}".utf8)
            )
        )

        XCTAssertTrue(completions.isEmpty)
        XCTAssertTrue(events.contains { event in
            if case .content(_, .unsupported) = event { return true }
            return false
        })
    }

    func testChannelSourcedHandoffBecomesAHostAction() {
        let session = SessionSpy()
        let repository = TanyaAISessionRepository(session: session)
        var events: [TanyaAIStreamEvent] = []

        repository.sendMessage(
            conversationIdentifier: nil,
            text: "Transfer",
            onEvent: { events.append($0) },
            completion: { _ in }
        )
        session.emit(
            .hostAction(
                identifier: "vendor-handoff",
                deeplink: "ocbcid://mobile?type=transfer"
            )
        )

        let actions = events.compactMap { event -> TanyaAIAction? in
            guard case .hostAction(let action) = event else {
                return nil
            }
            return action
        }
        XCTAssertEqual(actions.count, 1)
        XCTAssertEqual(actions.first?.deeplink, "ocbcid://mobile?type=transfer")
    }

    func testContextTravelsWithEveryMessageUntilItIsCleared() {
        let session = SessionSpy()
        let repository = TanyaAISessionRepository(
            session: session,
            context: TanyaAIContext(
                screen: "transfer.form",
                parameters: ["amount": "1250000"],
                summary: "About: transfer"
            )
        )

        repository.sendMessage(
            conversationIdentifier: nil,
            text: "Halo",
            onEvent: { _ in },
            completion: { _ in }
        )
        repository.updateContext(nil)
        repository.sendMessage(
            conversationIdentifier: nil,
            text: "Lagi",
            onEvent: { _ in },
            completion: { _ in }
        )

        XCTAssertEqual(session.sentContexts.count, 2)
        XCTAssertEqual(session.sentContexts[0]?.screen, "transfer.form")
        XCTAssertEqual(
            session.sentContexts[0]?.parameters["amount"],
            "1250000"
        )
        XCTAssertNil(session.sentContexts[1] ?? nil)
    }

    func testEventsOutsideATurnReachTheUnsolicitedObserver() {
        let session = SessionSpy()
        let repository = TanyaAISessionRepository(session: session)
        var unsolicited: [TanyaAIStreamEvent] = []
        repository.observeUnsolicitedEvents { unsolicited.append($0) }

        session.emit(.typing(true))
        session.emit(.messageStarted(messageIdentifier: "agent-1"))

        XCTAssertEqual(unsolicited.count, 2)
    }

    func testSessionFailureEndsTheTurnWithAnError() {
        let session = SessionSpy()
        let repository = TanyaAISessionRepository(session: session)
        var completions: [Result<Void, Error>] = []

        repository.sendMessage(
            conversationIdentifier: nil,
            text: "Halo",
            onEvent: { _ in },
            completion: { completions.append($0) }
        )
        session.emit(.failed(SessionError.dropped))

        XCTAssertEqual(completions.count, 1)
        guard case .failure = completions[0] else {
            return XCTFail("Expected the turn to fail")
        }
    }

    private var actionCardJSON: Data {
        let payload: [String: Any] = [
            "messageIdentifier": "card-1",
            "title": "Continue in the app",
            "actions": [
                [
                    "title": "Open transfer",
                    "action": [
                        "identifier": "open-transfer",
                        "deeplink": "ocbcid://mobile?type=transfer"
                    ]
                ]
            ]
        ]
        return (try? JSONSerialization.data(
            withJSONObject: payload,
            options: [.sortedKeys]
        )) ?? Data()
    }
}

private enum SessionError: Error {
    case dropped
}

private final class SessionSpy: TanyaAIChatSession {
    var onEvent: ((TanyaAIChatSessionEvent) -> Void)?
    private(set) var sentTexts: [String] = []
    private(set) var sentContexts: [TanyaAIContext?] = []
    private(set) var isConnected = false

    func connect() {
        isConnected = true
    }

    func send(
        text: String,
        context: TanyaAIContext?,
        requestIdentifier: String
    ) {
        sentTexts.append(text)
        sentContexts.append(context)
    }

    func disconnect() {
        isConnected = false
    }

    func emit(_ event: TanyaAIChatSessionEvent) {
        onEvent?(event)
    }
}
