import Foundation
import TanyaAIContracts
import TanyaAIDomain
import XCTest
@testable import TanyaAIPresentation

final class TanyaAIChatBehaviorTests: XCTestCase {
    func testBlankAndConcurrentMessagesAreIgnored() {
        let useCase = ChatUseCaseBehaviorStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)

        viewModel.sendMessage("   ")
        viewModel.sendMessage("First request")
        viewModel.sendMessage("Second request")

        XCTAssertEqual(useCase.receivedTexts, ["First request"])
        XCTAssertEqual(viewModel.messages.count, 2)
        XCTAssertTrue(viewModel.isGenerating)
    }

    func testCancellationStopsRequestAndFlushesText() {
        let useCase = ChatUseCaseBehaviorStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        viewModel.sendMessage("Start request")
        useCase.send(
            .textDelta(messageIdentifier: "assistant", text: "Partial")
        )

        viewModel.cancelGeneration()

        XCTAssertTrue(useCase.cancellable.isCancelled)
        XCTAssertFalse(viewModel.isGenerating)
        XCTAssertEqual(viewModel.messages.last?.content, .text("Partial"))
    }

    func testFailurePreservesConversationAndShowsError() {
        let useCase = ChatUseCaseBehaviorStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        viewModel.sendMessage("Start request")

        useCase.complete(.failure(ChatBehaviorError.interrupted))

        XCTAssertFalse(viewModel.isGenerating)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.messages.count, 2)
    }

    func testNavigationActionsProduceOutputs() {
        let viewModel = TanyaAIChatViewModel(
            useCase: ChatUseCaseBehaviorStub()
        )
        var outputs: [TanyaAIChatOutput] = []
        viewModel.onOutput = { outputs.append($0) }

        viewModel.openHistory()
        viewModel.close()

        XCTAssertEqual(outputs.count, 2)
        guard case .openHistory = outputs[0], case .close = outputs[1] else {
            return XCTFail("Expected history and close outputs")
        }
    }

    func testApprovalEditCancelAndStateGuard() {
        let useCase = ChatUseCaseBehaviorStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        let approval = makeApproval()
        var approvalOutputCount = 0
        viewModel.onOutput = { output in
            if case .requestApproval = output {
                approvalOutputCount += 1
            }
        }
        viewModel.sendMessage("Create transfer")
        useCase.send(
            .content(
                messageIdentifier: "approval-message",
                content: .approval(approval)
            )
        )

        viewModel.editApproval(approval)
        XCTAssertTrue(viewModel.inputText.hasPrefix("Change"))
        viewModel.cancelApproval(approval)
        guard case .approval(let cancelled) = viewModel.messages.last?.content else {
            return XCTFail("Expected cancelled approval")
        }
        XCTAssertEqual(cancelled.state, .cancelled)
        viewModel.approve(cancelled)
        XCTAssertEqual(approvalOutputCount, 0)
    }

    func testContentReplacesExistingPlaceholder() {
        let useCase = ChatUseCaseBehaviorStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        viewModel.sendMessage("Show status")
        useCase.send(.responseStarted(messageIdentifier: "assistant"))
        let status = TanyaAIStatusPayload(
            title: "Completed",
            detail: "Sanitized result",
            level: .success
        )

        useCase.send(
            .content(
                messageIdentifier: "assistant",
                content: .status(status)
            )
        )

        XCTAssertEqual(viewModel.messages.last?.content, .status(status))
    }

    private func makeApproval() -> TanyaAIApprovalPayload {
        TanyaAIApprovalPayload(
            approvalIdentifier: "approval-demo",
            transactionIdentifier: "transaction-demo",
            challengeIdentifier: "challenge-demo",
            kind: .transfer,
            title: "Confirm transfer",
            summary: [],
            expiresAt: Date().addingTimeInterval(300),
            state: .awaitingApproval
        )
    }
}

private enum ChatBehaviorError: Error {
    case interrupted
}

private final class ChatUseCaseBehaviorStub: TanyaAIChatUseCaseProtocol {
    let cancellable = ChatCancellableSpy()
    private var eventHandler: ((TanyaAIStreamEvent) -> Void)?
    private var completionHandler: ((Result<Void, Error>) -> Void)?
    private(set) var receivedTexts: [String] = []

    func sendMessage(
        conversationIdentifier: String?,
        text: String,
        onEvent: @escaping (TanyaAIStreamEvent) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable {
        receivedTexts.append(text)
        eventHandler = onEvent
        completionHandler = completion
        return cancellable
    }

    func send(_ event: TanyaAIStreamEvent) {
        eventHandler?(event)
    }

    func complete(_ result: Result<Void, Error>) {
        completionHandler?(result)
    }
}

private final class ChatCancellableSpy: TanyaAICancellable {
    private(set) var isCancelled = false

    func cancel() {
        isCancelled = true
    }
}
