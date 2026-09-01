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

    func testChannelSourcedActionLeavesThroughTheSameOutput() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        var received: [TanyaAIAction] = []
        viewModel.onOutput = { output in
            if case .performAction(let action) = output {
                received.append(action)
            }
        }
        let action = TanyaAIAction(
            identifier: "vendor-handoff",
            deeplink: "ocbcid://mobile?type=transfer"
        )

        useCase.sendUnsolicited(.hostAction(action))

        XCTAssertEqual(received, [action])
        XCTAssertEqual(viewModel.messages.count, 1)
    }

    func testAgentTypingDrivesTheIndicatorWithoutStartingAGeneration() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)

        useCase.sendUnsolicited(.typing(true))

        XCTAssertTrue(viewModel.isAgentTyping)
        XCTAssertFalse(viewModel.isGenerating)
    }

    func testSelectingSuggestionSendsItsPrompt() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        let suggestion = viewModel.suggestions[0]

        viewModel.sendSuggestion(suggestion)

        XCTAssertEqual(useCase.receivedText, suggestion.prompt)
        XCTAssertFalse(viewModel.showsSuggestions)
    }

    func testBackendSuggestionsReplaceInitialSuggestions() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        viewModel.sendMessage("Show spending")

        useCase.send(
            .suggestions([
                TanyaAISuggestionPayload(
                    identifier: "next-question",
                    title: "Next question",
                    prompt: "Show the next answer"
                )
            ])
        )
        useCase.send(.responseCompleted(messageIdentifier: "assistant-1"))

        XCTAssertTrue(viewModel.showsSuggestions)
        XCTAssertEqual(viewModel.suggestions.map(\.title), ["Next question"])
    }

    func testEveryConfirmationKindProducesApprovalOutput() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        var receivedKinds: [TanyaAIApprovalPayload.Kind] = []
        viewModel.onOutput = { output in
            if case .requestApproval(let payload) = output {
                receivedKinds.append(payload.kind)
            }
        }

        TanyaAIApprovalPayload.Kind.allCasesForTests.forEach { kind in
            viewModel.approve(makeApproval(kind: kind))
        }

        XCTAssertEqual(receivedKinds, TanyaAIApprovalPayload.Kind.allCasesForTests)
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

    private func makeApproval(
        kind: TanyaAIApprovalPayload.Kind = .generic
    ) -> TanyaAIApprovalPayload {
        TanyaAIApprovalPayload(
            approvalIdentifier: "approval-demo",
            transactionIdentifier: "transaction-demo",
            challengeIdentifier: "challenge-demo",
            kind: kind,
            title: "Approve demo",
            summary: [],
            expiresAt: Date().addingTimeInterval(300),
            state: .awaitingApproval
        )
    }
}

private extension TanyaAIApprovalPayload.Kind {
    static let allCasesForTests: [Self] = [
        .currencyConversion,
        .timeDeposit,
        .transfer,
        .savingsPlan
    ]
}

private final class TanyaAIChatUseCaseStub: TanyaAIChatUseCaseProtocol {
    private var eventHandler: ((TanyaAIStreamEvent) -> Void)?
    private var completionHandler: ((Result<Void, Error>) -> Void)?
    private var unsolicitedHandler: ((TanyaAIStreamEvent) -> Void)?
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

    func observeUnsolicitedEvents(
        _ onEvent: @escaping (TanyaAIStreamEvent) -> Void
    ) {
        unsolicitedHandler = onEvent
    }

    func send(_ event: TanyaAIStreamEvent) {
        eventHandler?(event)
    }

    func sendUnsolicited(_ event: TanyaAIStreamEvent) {
        unsolicitedHandler?(event)
    }

    func complete(_ result: Result<Void, Error>) {
        completionHandler?(result)
    }
}
