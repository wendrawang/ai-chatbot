import TanyaAIContracts
import TanyaAIDomain
import XCTest
@testable import TanyaAIData

final class TanyaAISessionStartupTests: XCTestCase {
    func testSynchronousHistoryDuringConnectReachesTheObserver() {
        let session = SessionSpy()
        session.connectionEvents = [
            .history([TanyaAIChatSessionMessage(
                identifier: "existing", author: .assistant, text: "Welcome back"
            )]),
            .connected
        ]
        let repository = TanyaAISessionRepository(session: session)
        var restored: [TanyaAIMessage] = []

        repository.observeUnsolicitedEvents { event in
            if case .history(let messages) = event { restored = messages }
        }

        XCTAssertEqual(restored.map(\.identifier), ["existing"])
        withExtendedLifetime(repository) {}
    }

    func testSynchronousConnectionEndsTheRestoringState() {
        let session = SessionSpy()
        session.connectionEvents = [.connected]
        let repository = TanyaAISessionRepository(session: session)
        var historyCount = 0

        repository.observeUnsolicitedEvents { event in
            if case .history = event { historyCount += 1 }
        }

        XCTAssertEqual(historyCount, 1)
        withExtendedLifetime(repository) {}
    }
}
