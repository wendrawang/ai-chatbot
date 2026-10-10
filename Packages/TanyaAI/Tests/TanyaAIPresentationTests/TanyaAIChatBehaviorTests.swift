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
            repository: TanyaAIRepositoryStub()
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
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(repository: repository)
        let approval = makeApproval()
        var approvalOutputCount = 0
        viewModel.onOutput = { output in
            if case .requestApproval = output {
                approvalOutputCount += 1
            }
        }
        viewModel.sendMessage("Create transfer")
        repository.send(
            .content(
                messageIdentifier: "approval-message",
                content: .approval(approval)
            )
        )

        viewModel.editApproval(approval)
        XCTAssertTrue((viewModel.draftRequest?.text.hasPrefix("Change") == true))
        viewModel.cancelApproval(approval)
        guard case .approval(let cancelled) = viewModel.messages.last?.content else {
            return XCTFail("Expected cancelled approval")
        }
        XCTAssertEqual(cancelled.state, .cancelled)
        viewModel.approve(cancelled)
        XCTAssertEqual(approvalOutputCount, 0)
    }

    func testContentReplacesExistingPlaceholder() {
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(repository: repository)
        viewModel.sendMessage("Show status")
        repository.send(.responseStarted(messageIdentifier: "assistant"))
        let status = StatusPayload(
            title: "Completed",
            detail: "Sanitized result",
            level: .success
        )

        repository.send(
            .content(
                messageIdentifier: "assistant",
                content: .status(status)
            )
        )

        XCTAssertEqual(viewModel.messages.last?.content, .status(status))
    }

    private func makeApproval() -> ApprovalPayload {
        ApprovalPayload(
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
