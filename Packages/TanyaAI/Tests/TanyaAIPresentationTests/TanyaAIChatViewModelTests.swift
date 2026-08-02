import Foundation
import TanyaAIContracts
import TanyaAIDomain
import XCTest
@testable import TanyaAIPresentation

final class TanyaAIChatViewModelTests: XCTestCase {
    func testSendingMessageAddsUserAndStreamedAssistantMessages() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        viewModel.inputText = "Hello"

        viewModel.sendCurrentMessage()
        useCase.send(.responseStarted(messageIdentifier: "assistant-1"))
        useCase.send(
            .textDelta(messageIdentifier: "assistant-1", text: "Hi there")
        )
        useCase.complete(.success(()))

        XCTAssertEqual(viewModel.messages.count, 3)
        XCTAssertEqual(viewModel.messages[1].content, .text("Hello"))
        XCTAssertEqual(viewModel.messages[2].content, .text("Hi there"))
        XCTAssertFalse(viewModel.isGenerating)
    }

    func testApprovalActionProducesTypedOutput() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        let approval = makeApproval()
        var receivedApproval: TanyaAIApprovalPayload?
        viewModel.onOutput = { output in
            if case .requestApproval(let payload) = output {
                receivedApproval = payload
            }
        }

        viewModel.approve(approval)

        XCTAssertEqual(receivedApproval, approval)
    }

    func testSelectingSuggestionSendsItsPrompt() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        let suggestion = viewModel.suggestions[0]

        viewModel.sendSuggestion(suggestion)

        XCTAssertEqual(useCase.receivedText, suggestion.prompt)
        XCTAssertFalse(viewModel.showsSuggestions)
    }

    func testApprovalStateUpdatesExistingMessage() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        let approval = makeApproval()
        viewModel.inputText = "Create transfer"
        viewModel.sendCurrentMessage()
        useCase.send(
            .content(
                messageIdentifier: "approval-message",
                content: .approval(approval)
            )
        )

        viewModel.updateApproval(
            identifier: approval.approvalIdentifier,
            state: .completed
        )

        guard case .approval(let updatedApproval) =
                viewModel.messages.last?.content else {
            return XCTFail("Expected approval message")
        }
        XCTAssertEqual(updatedApproval.state, .completed)
    }

    private func makeApproval() -> TanyaAIApprovalPayload {
        TanyaAIApprovalPayload(
            approvalIdentifier: "approval-demo",
            transactionIdentifier: "transaction-demo",
            challengeIdentifier: "challenge-demo",
            title: "Approve demo",
            summary: [],
            expiresAt: Date().addingTimeInterval(300),
            state: .awaitingApproval
        )
    }
}

private final class TanyaAIChatUseCaseStub: TanyaAIChatUseCaseProtocol {
    private var eventHandler: ((TanyaAIStreamEvent) -> Void)?
    private var completionHandler: ((Result<Void, Error>) -> Void)?
    private(set) var receivedText: String?

    func sendMessage(
        conversationIdentifier: String?,
        text: String,
        onEvent: @escaping (TanyaAIStreamEvent) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable {
        receivedText = text
        eventHandler = onEvent
        completionHandler = completion
        return TanyaAINoOpCancellable()
    }

    func send(_ event: TanyaAIStreamEvent) {
        eventHandler?(event)
    }

    func complete(_ result: Result<Void, Error>) {
        completionHandler?(result)
    }
}
