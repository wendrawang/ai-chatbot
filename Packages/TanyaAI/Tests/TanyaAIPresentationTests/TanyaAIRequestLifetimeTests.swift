import TanyaAIDomain
import XCTest
@testable import TanyaAIPresentation

@MainActor
final class TanyaAIRequestLifetimeTests: XCTestCase {
    func testAcknowledgementOnlyUpdatesTheMatchingSubmission() {
        let repository = TanyaAIRepositoryStub()
        repository.isAutomaticAcknowledgement = false
        let model = TanyaAIChatViewModel(repository: repository)
        model.sendMessage("First")
        model.sendMessage("Second")
        repository.send(.sendSucceeded(requestIdentifier: repository.requestIdentifiers[0], messageIdentifier: "first"))
        XCTAssertEqual(model.messages[0].delivery, .sent)
        XCTAssertEqual(model.messages[1].delivery, .pending)
        repository.send(.sendFailed(requestIdentifier: repository.requestIdentifiers[1]))
        XCTAssertEqual(model.messages[1].delivery, .failed)
    }

    func testRetryUsesTheSameRowAndIgnoresTheOldAcknowledgement() {
        let repository = TanyaAIRepositoryStub()
        repository.isAutomaticAcknowledgement = false
        let model = TanyaAIChatViewModel(repository: repository)
        model.sendMessage("First")
        let oldIdentifier = repository.requestIdentifiers[0]
        let row = model.messages[0]
        repository.send(.sendFailed(requestIdentifier: oldIdentifier))
        model.retryMessage(row.identifier)
        XCTAssertTrue(model.messages[0] === row)
        XCTAssertEqual(row.delivery, .pending)
        repository.send(.sendSucceeded(requestIdentifier: oldIdentifier, messageIdentifier: "old"))
        XCTAssertEqual(row.delivery, .pending)
        repository.send(.sendSucceeded(requestIdentifier: repository.requestIdentifiers[1], messageIdentifier: "retry"))
        XCTAssertEqual(row.delivery, .sent)
        XCTAssertEqual(model.messages.count, 1)
    }

    func testEventCallbackDoesNotKeepViewModelAlive() {
        let repository = TanyaAIRepositoryStub()
        weak var released: TanyaAIChatViewModel?
        autoreleasepool {
            let model = TanyaAIChatViewModel(repository: repository)
            released = model
        }
        XCTAssertNil(released)
        XCTAssertNil(repository.onEvent)
        XCTAssertEqual(repository.disconnectCount, 1)
    }
}
