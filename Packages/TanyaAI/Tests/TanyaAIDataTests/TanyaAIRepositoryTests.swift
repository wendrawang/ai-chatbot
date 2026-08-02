import Foundation
import TanyaAIDomain
import TanyaAITestSupport
import XCTest
@testable import TanyaAIData

final class TanyaAIRepositoryTests: XCTestCase {
    func testRepositoryMapsFragmentedDemoStream() {
        let receivedEvents = events(for: "Show my sample portfolio")

        XCTAssertTrue(receivedEvents.contains { event in
            if case .content(_, .portfolio(_)) = event { return true }
            return false
        })
    }

    func testRepositoryMapsInformationContent() {
        let receivedEvents = events(for: "What is my transfer limit?")

        XCTAssertTrue(receivedEvents.contains { event in
            if case .content(_, .information(_)) = event { return true }
            return false
        })
    }

    func testRepositoryMapsChartContent() {
        let receivedEvents = events(for: "Show my spending insight")

        XCTAssertTrue(receivedEvents.contains { event in
            if case .content(_, .chart(_)) = event { return true }
            return false
        })
    }

    func testRepositoryMapsApprovalContent() {
        let receivedEvents = events(for: "Create a sample transfer")

        XCTAssertTrue(receivedEvents.contains { event in
            if case .content(_, .approval(_)) = event { return true }
            return false
        })
    }

    private func events(for message: String) -> [TanyaAIStreamEvent] {
        let completionExpectation = expectation(description: "stream completes")
        let transport = MockTanyaAIStreamingTransport(
            callbackQueue: DispatchQueue(label: "repository.test"),
            chunkDelay: 0.001
        )
        let repository = DefaultTanyaAIRepository(
            transport: transport,
            messagePath: "/sandbox/messages"
        )
        var receivedEvents: [TanyaAIStreamEvent] = []

        _ = repository.sendMessage(
            conversationIdentifier: nil,
            text: message,
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
