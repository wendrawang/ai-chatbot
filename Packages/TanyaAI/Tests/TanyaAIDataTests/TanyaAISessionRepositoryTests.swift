import Foundation
import TanyaAIContracts
import TanyaAIDomain
import XCTest

@testable import TanyaAIData

final class TanyaAISessionRepositoryTests: XCTestCase {
    func testStartupFailureIsReportedWithoutSendingAnything() {
        let session = SessionSpy()
        session.connectionEvents = [.failed(SessionError.dropped)]
        let repository = TanyaAISessionRepository(session: session)
        let recorder = SessionRecorder()
        recorder.attach(repository)
        recorder.wait(.connectionChanged(.failed), in: self)
        XCTAssertTrue(session.sentTexts.isEmpty)
    }

    func testTextReplyAndSDKSubmissionHaveIndependentCompletions() {
        let session = SessionSpy()
        session.connectionEvents = [.connected]
        let repository = TanyaAISessionRepository(session: session)
        let recorder = SessionRecorder()
        recorder.attach(repository)
        recorder.wait(.connectionChanged(.ready), in: self)
        repository.sendMessage(text: "A", requestIdentifier: "A")
        repository.sendMessage(text: "B", requestIdentifier: "B")
        session.emit(.messageDelta(messageIdentifier: "late-A", text: "Late"))
        session.emit(.messageCompleted(messageIdentifier: "late-A"))
        recorder.wait(.responseCompleted(messageIdentifier: "late-A"), in: self)
        XCTAssertFalse(
            recorder.events.contains {
                if case .sendSucceeded = $0 { return true }; return false
            })
        session.emit(.sendSucceeded(requestIdentifier: "B", messageIdentifier: "sdk-B"))
        recorder.wait(.sendSucceeded(requestIdentifier: "B", messageIdentifier: "sdk-B"), in: self)
        XCTAssertEqual(session.sentTexts, ["A", "B"])
    }

    func testSendFailureDoesNotCloseTheChannel() {
        let session = SessionSpy()
        session.connectionEvents = [.connected]
        let repository = TanyaAISessionRepository(session: session)
        let recorder = SessionRecorder()
        recorder.attach(repository)
        recorder.wait(.connectionChanged(.ready), in: self)
        session.emit(.sendFailed(requestIdentifier: "A", error: SessionError.dropped))
        recorder.wait(.sendFailed(requestIdentifier: "A"), in: self)
        repository.sendMessage(text: "B", requestIdentifier: "B")
        XCTAssertEqual(session.sentTexts, ["B"])
        XCTAssertFalse(recorder.events.contains(.connectionChanged(.failed)))
    }

    func testRetryRejectsCallbacksFromTheOldConnection() {
        let session = SessionSpy()
        session.connectionEvents = [.connected]
        let repository = TanyaAISessionRepository(session: session)
        let recorder = SessionRecorder()
        recorder.attach(repository)
        recorder.wait(.connectionChanged(.ready), in: self)
        let oldCallback = session.onEvent
        repository.disconnect()
        repository.connect()
        oldCallback?(.history([TanyaAIChatSessionMessage(identifier: "stale", author: .assistant, text: "Stale")]))
        session.emit(.messageCompleted(messageIdentifier: "new"))
        recorder.wait(.responseCompleted(messageIdentifier: "new"), in: self)
        XCTAssertFalse(recorder.history?.contains { $0.identifier == "stale" } == true)
    }

    func testLiveMessagesWaitForTheHistorySnapshot() {
        let session = SessionSpy()
        let repository = TanyaAISessionRepository(session: session)
        let recorder = SessionRecorder()
        recorder.attach(repository)
        session.emit(.messageDelta(messageIdentifier: "live", text: "New"))
        session.emit(.history([TanyaAIChatSessionMessage(identifier: "old", author: .customer, text: "Old")]))
        session.emit(.connected)
        recorder.wait(.connectionChanged(.ready), in: self)
        let relevant = recorder.events.filter {
            if case .history = $0 { return true }
            if case .textDelta = $0 { return true }
            return false
        }
        guard case .history = relevant.first else { return XCTFail("History must precede live content") }
        XCTAssertEqual(relevant.last, .textDelta(messageIdentifier: "live", text: "New"))
    }

    func testHistoryFailureStillAllowsConnectedChannelToSend() {
        let session = SessionSpy()
        session.connectionEvents = [.historyFailed(SessionError.dropped), .connected]
        let repository = TanyaAISessionRepository(session: session)
        let recorder = SessionRecorder()
        recorder.attach(repository)
        recorder.wait(.connectionChanged(.ready), in: self)
        XCTAssertTrue(recorder.events.contains(.historyFailed))
        XCTAssertNil(recorder.history)
        repository.sendMessage(text: "Hello", requestIdentifier: "A")
        XCTAssertEqual(session.sentTexts, ["Hello"])
    }

    func testReleasingRepositoryDisconnectsAndClearsTheCallback() {
        let session = SessionSpy()
        autoreleasepool {
            let repository = TanyaAISessionRepository(session: session)
            repository.connect()
        }
        XCTAssertFalse(session.isConnected)
        XCTAssertNil(session.onEvent)
    }

    func testContextTravelsWithSubmissionsUntilCleared() {
        let session = SessionSpy()
        session.connectionEvents = [.connected]
        let repository = TanyaAISessionRepository(session: session, context: TanyaAIContext(screen: "transfer"))
        let recorder = SessionRecorder()
        recorder.attach(repository)
        recorder.wait(.connectionChanged(.ready), in: self)
        repository.sendMessage(text: "A", requestIdentifier: "A")
        repository.updateContext(nil)
        repository.sendMessage(text: "B", requestIdentifier: "B")
        XCTAssertEqual(session.sentContexts[0]?.screen, "transfer")
        XCTAssertNil(session.sentContexts[1])
    }

    func testMalformedPayloadBecomesAnUnsupportedCard() {
        let session = SessionSpy()
        session.connectionEvents = [.connected]
        let repository = TanyaAISessionRepository(session: session)
        let recorder = SessionRecorder()
        recorder.attach(repository)
        session.emit(.structuredPayload(name: "content.approval", json: Data("bad".utf8)))
        session.emit(.messageCompleted(messageIdentifier: "barrier"))
        recorder.wait(.responseCompleted(messageIdentifier: "barrier"), in: self)
        XCTAssertTrue(
            recorder.events.contains {
                if case .content(_, .unsupported) = $0 { return true }; return false
            })
    }
}
