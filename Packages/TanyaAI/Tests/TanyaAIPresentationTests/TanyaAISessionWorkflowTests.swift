import DesignKit
import TanyaAIDomain
import XCTest
@testable import TanyaAIPresentation

@MainActor
final class TanyaAISessionWorkflowTests: XCTestCase {
    func testStartupFailureSettlesLoadingAndRetryRestoresReadiness() {
        let repository = TanyaAIRepositoryStub()
        repository.isAutomaticConnection = false
        let model = TanyaAIChatViewModel(repository: repository)
        repository.send(.connectionChanged(.failed))
        XCTAssertFalse(model.isRestoring)
        XCTAssertNotNil(model.errorMessage)
        XCTAssertTrue(model.isSessionRetryAvailable)
        repository.isAutomaticConnection = true
        model.retrySession()
        XCTAssertTrue(model.isSendEnabled)
        XCTAssertNil(model.errorMessage)
        XCTAssertEqual(repository.disconnectCount, 1)
    }

    func testInitialPromptWaitsForReadinessAndRunsOnlyOnce() {
        let repository = TanyaAIRepositoryStub()
        repository.isAutomaticConnection = false
        let model = TanyaAIChatViewModel(repository: repository)
        model.startInitialPrompt("Initial")
        XCTAssertTrue(repository.receivedTexts.isEmpty)
        repository.send(.history([]))
        repository.send(.connectionChanged(.ready))
        model.startInitialPrompt("Other")
        repository.send(.connectionChanged(.failed))
        repository.isAutomaticConnection = true
        model.retrySession()
        XCTAssertEqual(repository.receivedTexts, ["Initial"])
    }

    func testHistoryReloadPreservesFailedOutboxAndDeduplicatesSDKRows() {
        let repository = TanyaAIRepositoryStub()
        repository.isAutomaticAcknowledgement = false
        let model = TanyaAIChatViewModel(repository: repository)
        model.sendMessage("Delivered")
        let firstRequest = repository.requestIdentifiers[0]
        let delivered = model.messages[0]
        model.sendMessage("Failed")
        repository.send(.sendFailed(requestIdentifier: repository.requestIdentifiers[1]))
        repository.send(.history([
            TanyaAIMessage(identifier: "sdk-" + firstRequest, role: .user, content: .text("Delivered")),
            TanyaAIMessage(identifier: "sdk-" + firstRequest, role: .user, content: .text("Delivered"))
        ]))
        XCTAssertEqual(model.messages.count, 2)
        XCTAssertTrue(model.messages[0] === delivered)
        XCTAssertEqual(model.messages[0].delivery, .sent)
        XCTAssertEqual(model.messages[1].delivery, .failed)
    }

    func testHistoryWarningDoesNotDisableSendingWhenChannelIsReady() {
        let repository = TanyaAIRepositoryStub()
        let model = TanyaAIChatViewModel(repository: repository)
        repository.send(.historyFailed)
        XCTAssertTrue(model.isHistoryUnavailable)
        XCTAssertTrue(model.isSessionRetryAvailable)
        XCTAssertTrue(model.sendMessage("New message"))
    }

    func testMultipleChoiceIsNotConsumedWhileUnavailableAndSendsWhileTyping() {
        let repository = TanyaAIRepositoryStub()
        let model = TanyaAIChatViewModel(repository: repository)
        let payload = ChoicesPayload(identifier: "choices", title: nil, choices: [
            .init(identifier: "one", title: "One", prompt: "One")
        ], isMultipleSelectionAllowed: true, selected: ["one"])
        repository.send(.content(messageIdentifier: "choices", content: .choices(payload)))
        repository.send(.connectionChanged(.failed))
        model.submitChoices(payload)
        guard case .choices(let unchanged) = model.messages[0].content else { return XCTFail("Missing choices") }
        XCTAssertFalse(unchanged.isSubmitted)
        repository.send(.connectionChanged(.ready))
        repository.send(.typing(true))
        model.submitChoices(payload)
        model.submitChoices(payload)
        XCTAssertEqual(repository.receivedTexts, ["One"])
        guard case .choices(let submitted) = model.messages[0].content else { return XCTFail("Missing choices") }
        XCTAssertTrue(submitted.isSubmitted)
    }
}
