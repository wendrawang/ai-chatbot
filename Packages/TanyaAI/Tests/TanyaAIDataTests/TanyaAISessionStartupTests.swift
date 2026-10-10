import TanyaAIContracts
import TanyaAIDomain
import XCTest
@testable import TanyaAIData

final class TanyaAISessionStartupTests: XCTestCase {
    func testSynchronousHistoryIsNotOverwrittenByAnEmptyBatch() {
        let session = SessionSpy()
        session.connectionEvents = [
            .history([TanyaAIChatSessionMessage(identifier: "old", author: .customer, text: "Old")]), .connected
        ]
        let repository = TanyaAISessionRepository(session: session)
        let recorder = SessionRecorder()
        recorder.attach(repository)
        recorder.wait(.connectionChanged(.ready), in: self)
        XCTAssertEqual(recorder.history?.map(\.identifier), ["old"])
        XCTAssertEqual(recorder.events.filter { if case .history = $0 { return true }; return false }.count, 1)
    }

    func testSynchronousConnectionWithoutHistoryProducesOneEmptySnapshot() {
        let session = SessionSpy()
        session.connectionEvents = [.connected]
        let repository = TanyaAISessionRepository(session: session)
        let recorder = SessionRecorder()
        recorder.attach(repository)
        recorder.wait(.connectionChanged(.ready), in: self)
        XCTAssertEqual(recorder.history?.count, 0)
    }
}
