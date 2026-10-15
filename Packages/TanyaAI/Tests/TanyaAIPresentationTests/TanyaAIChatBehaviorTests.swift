import DesignKit
import Foundation
import TanyaAIContracts
import TanyaAIDomain
import XCTest

@testable import TanyaAIPresentation

@MainActor
final class TanyaAIChatBehaviorTests: XCTestCase {
    func testBlankMessagesAreIgnoredAndNewContextCanBeSentWhileTyping() {
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(repository: repository)
        XCTAssertFalse(viewModel.sendMessage("   "))
        XCTAssertTrue(viewModel.sendMessage("First request"))
        repository.send(.typing(true))
        XCTAssertTrue(viewModel.sendMessage("Second request"))
        XCTAssertEqual(repository.receivedTexts, ["First request", "Second request"])
        XCTAssertEqual(viewModel.messages.count, 2)
        XCTAssertTrue(viewModel.isAgentTyping)
    }

    func testLateReplyOnlyFinishesItsOwnTextBuffer() {
        let repository = TanyaAIRepositoryStub()
        repository.isAutomaticAcknowledgement = false
        let viewModel = TanyaAIChatViewModel(repository: repository)
        viewModel.sendMessage("First")
        viewModel.sendMessage("Second")
        repository.send(.textDelta(messageIdentifier: "first-reply", text: "Late reply"))
        repository.send(.responseCompleted(messageIdentifier: "first-reply"))
        XCTAssertEqual(viewModel.messages[0].delivery, .pending)
        XCTAssertEqual(viewModel.messages[1].delivery, .pending)
        XCTAssertEqual(viewModel.messages.last?.content, .text("Late reply"))
    }

    func testFailurePreservesConversationAndShowsError() {
        let repository = TanyaAIRepositoryStub()
        repository.isAutomaticAcknowledgement = false
        let viewModel = TanyaAIChatViewModel(repository: repository)
        viewModel.sendMessage("Start request")
        repository.complete(.failure(ChatBehaviorError.interrupted))
        XCTAssertEqual(viewModel.messages.first?.delivery, .failed)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.messages.count, 1)
    }

    func testNavigationActionsProduceOutputs() {
        let viewModel = TanyaAIChatViewModel(
            repository: TanyaAIRepositoryStub(), isNewSessionEnabled: true
        )
        var outputs: [TanyaAIChatOutput] = []
        viewModel.onOutput = { outputs.append($0) }

        viewModel.startNewSession()
        viewModel.close()

        XCTAssertEqual(outputs.count, 2)
        guard case .startNewSession = outputs[0], case .close = outputs[1] else {
            return XCTFail("Expected new session and close outputs")
        }
    }

    func testContentReplacesExistingPlaceholder() {
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(repository: repository)
        viewModel.sendMessage("Show status")
        repository.send(.responseStarted(messageIdentifier: "assistant"))
        let response = ResponsePayload(blocks: [.text("Completed"), .note("Sanitized result")])

        repository.send(
            .content(
                messageIdentifier: "assistant",
                content: .response(response)
            )
        )

        XCTAssertEqual(viewModel.messages.last?.content, .response(response))
    }

}

private enum ChatBehaviorError: Error {
    case interrupted
}
