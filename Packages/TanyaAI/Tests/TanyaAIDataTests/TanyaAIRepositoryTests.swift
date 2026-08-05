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

    func testRepositoryMapsDynamicSuggestions() {
        let receivedEvents = events(for: "Show my spending insight")

        XCTAssertTrue(receivedEvents.contains { event in
            guard case .suggestions(let suggestions) = event else {
                return false
            }
            return suggestions.isEmpty == false
        })
    }

    func testShowcaseMapsAllFinancialBubbleFamilies() {
        let receivedEvents = events(for: "showcase all bubbles")
        let contents = receivedEvents.compactMap { event -> TanyaAIMessageContent? in
            guard case .content(_, let content) = event else {
                return nil
            }
            return content
        }

        XCTAssertEqual(approvalKinds(in: contents).count, 4)
        XCTAssertEqual(financialListStyles(in: contents).count, 3)
        XCTAssertEqual(statusLevels(in: contents).count, 4)
        XCTAssertTrue(contents.contains { if case .information = $0 { return true }; return false })
        XCTAssertTrue(contents.contains { if case .receipt = $0 { return true }; return false })
        XCTAssertTrue(contents.contains { if case .chart = $0 { return true }; return false })
        XCTAssertTrue(contents.contains { if case .portfolio = $0 { return true }; return false })
        XCTAssertTrue(contents.contains { if case .unsupported = $0 { return true }; return false })
    }

    private func financialListStyles(
        in contents: [TanyaAIMessageContent]
    ) -> Set<TanyaAIFinancialListPayload.Style> {
        Set(contents.compactMap { content in
            guard case .financialList(let list) = content else {
                return nil
            }
            return list.style
        })
    }

    private func statusLevels(
        in contents: [TanyaAIMessageContent]
    ) -> Set<TanyaAIStatusPayload.Level> {
        Set(contents.compactMap { content in
            guard case .status(let status) = content else {
                return nil
            }
            return status.level
        })
    }

    private func approvalKinds(
        in contents: [TanyaAIMessageContent]
    ) -> Set<TanyaAIApprovalPayload.Kind> {
        Set(contents.compactMap { content in
            guard case .approval(let approval) = content else {
                return nil
            }
            return approval.kind
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
