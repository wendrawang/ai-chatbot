import Foundation
import TanyaAIDomain
import TanyaAITestSupport
import XCTest
@testable import TanyaAIData

/// Proves the fixture a host uses to test its deeplink hand-off produces a
/// stream the package actually decodes, and that the deeplink reaches the
/// other side unchanged.
final class TanyaAIActionFixtureTests: XCTestCase {
    private let deeplink = "ocbcid://mobile?type=transfer&amount=1250000"

    func testActionCardFixtureDeliversTheDeeplinkUnchanged() {
        let events = events(
            for: MockTanyaAIActionFixture.actionCardChunks(
                buttons: [
                    MockTanyaAIActionFixture.Button(
                        title: "Open transfer",
                        deeplink: deeplink,
                        identifier: "open-transfer"
                    )
                ]
            )
        )

        let buttons = events.compactMap { event -> [TanyaAIActionButton]? in
            guard case .content(_, .actions(let payload)) = event else {
                return nil
            }
            return payload.buttons
        }.flatMap { $0 }

        XCTAssertEqual(buttons.count, 1)
        XCTAssertEqual(buttons.first?.action.identifier, "open-transfer")
        XCTAssertEqual(buttons.first?.action.deeplink, deeplink)
    }

    func testApprovalHandoffFixtureCarriesTheDeeplink() {
        let events = events(
            for: MockTanyaAIActionFixture.approvalHandoffChunks(
                deeplink: deeplink
            )
        )

        let approvals = events.compactMap { event -> TanyaAIApprovalPayload? in
            guard case .content(_, .approval(let payload)) = event else {
                return nil
            }
            return payload
        }

        XCTAssertEqual(approvals.count, 1)
        XCTAssertEqual(approvals.first?.handoff?.deeplink, deeplink)
    }

    private func events(for chunks: [Data]) -> [TanyaAIStreamEvent] {
        let completionExpectation = expectation(description: "stream completes")
        let transport = MockTanyaAIStreamingTransport(
            scenario: .custom(chunks),
            callbackQueue: DispatchQueue(label: "action.fixture.test"),
            chunkDelay: 0.001
        )
        let repository = DefaultTanyaAIRepository(
            transport: transport,
            messagePath: "/sandbox/messages"
        )
        var receivedEvents: [TanyaAIStreamEvent] = []

        _ = repository.sendMessage(
            conversationIdentifier: nil,
            text: "anything",
            onEvent: { receivedEvents.append($0) },
            completion: { result in
                if case .failure(let error) = result {
                    XCTFail("Unexpected error: \(error)")
                }
                completionExpectation.fulfill()
            }
        )

        wait(for: [completionExpectation], timeout: 2)
        return receivedEvents
    }
}
