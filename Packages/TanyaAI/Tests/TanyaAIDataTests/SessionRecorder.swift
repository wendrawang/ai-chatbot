import TanyaAIDomain
import XCTest

final class SessionRecorder {
    private(set) var events: [TanyaAIStreamEvent] = []
    var history: [TanyaAIMessage]? {
        events.compactMap { event in
            if case .history(let messages) = event { return messages }
            return nil
        }.last
    }
    func attach(_ repository: TanyaAIRepository) {
        repository.onEvent = { [weak self] event in
            XCTAssertTrue(Thread.isMainThread)
            self?.events.append(event)
        }
        repository.connect()
    }
    func wait(_ event: TanyaAIStreamEvent, in test: XCTestCase) {
        waitUntil(in: test) { self.events.contains(event) }
    }
    func waitUntil(in test: XCTestCase, _ condition: @escaping () -> Bool) {
        let predicate = NSPredicate { _, _ in condition() }
        test.wait(for: [XCTNSPredicateExpectation(predicate: predicate, object: nil)], timeout: 2)
    }
}
