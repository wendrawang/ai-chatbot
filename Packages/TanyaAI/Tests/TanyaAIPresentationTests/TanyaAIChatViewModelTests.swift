import DesignKit
import Foundation
import TanyaAIContracts
import TanyaAIDomain
import XCTest
@testable import TanyaAIPresentation

@MainActor
final class TanyaAIChatViewModelTests: XCTestCase {
    func testSendingMessageAddsUserAndStreamedAssistantMessages() {
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(repository: repository)
        viewModel.sendMessage("Hello")
        repository.send(.responseStarted(messageIdentifier: "assistant-1"))
        repository.send(
            .textDelta(messageIdentifier: "assistant-1", text: "Hi there")
        )
        repository.complete(.success(()))

        XCTAssertEqual(viewModel.messages.count, 2)
        XCTAssertEqual(viewModel.messages[0].content, .text("Hello"))
        XCTAssertEqual(viewModel.messages[1].content, .text("Hi there"))
        XCTAssertFalse(viewModel.isAgentTyping)
    }

    /// A bot that greets first, or any reply arriving between turns, still
    /// belongs on screen. The session reports these outside a turn, and
    /// nothing consumed them before.
    func testUnpromptedReplyIsRendered() {
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(repository: repository)
        let before = viewModel.messages.count

        repository.sendUnsolicited(.responseStarted(messageIdentifier: "greet"))
        repository.sendUnsolicited(
            .textDelta(messageIdentifier: "greet", text: "Halo!")
        )
        repository.sendUnsolicited(.responseCompleted(messageIdentifier: "greet"))

        XCTAssertEqual(viewModel.messages.count, before + 1)
        XCTAssertFalse(viewModel.isAgentTyping)
    }

    func testApprovalActionProducesTypedOutput() {
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(repository: repository)
        let approval = makeApproval()
        var receivedApproval: ApprovalPayload?
        viewModel.onOutput = { output in
            if case .requestApproval(let payload) = output {
                receivedApproval = payload
            }
        }

        viewModel.approve(approval)

        XCTAssertEqual(receivedApproval, approval)
    }

    func testSelectingSuggestionSendsItsPrompt() {
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(repository: repository)
        repository.sendUnsolicited(.history([]))
        repository.sendUnsolicited(.suggestions(title: nil, items: [
            TanyaAISuggestionPayload(
                identifier: "next-question", title: "Next question", prompt: "Show next answer"
            )
        ]))
        let suggestion = viewModel.suggestions[0]

        viewModel.sendSuggestion(suggestion)

        XCTAssertEqual(repository.receivedText, suggestion.prompt)
        XCTAssertFalse(viewModel.isSuggestionRowVisible)
    }

    func testBackendResponseShowsSuggestions() {
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(repository: repository)
        viewModel.sendMessage("Show spending")

        repository.send(
            .suggestions(title: "Pilih satu", items: [
                TanyaAISuggestionPayload(
                    identifier: "next-question",
                    title: "Next question",
                    prompt: "Show the next answer"
                )
            ])
        )
        repository.send(.responseCompleted(messageIdentifier: "assistant-1"))

        XCTAssertTrue(viewModel.isSuggestionRowVisible)
        XCTAssertEqual(viewModel.suggestions.map(\.title), ["Next question"])
    }

    func testEveryConfirmationKindProducesApprovalOutput() {
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(repository: repository)
        var receivedKinds: [ApprovalPayload.Kind] = []
        viewModel.onOutput = { output in
            if case .requestApproval(let payload) = output {
                receivedKinds.append(payload.kind)
            }
        }

        ApprovalPayload.Kind.allCasesForTests.forEach { kind in
            viewModel.approve(makeApproval(kind: kind))
        }

        XCTAssertEqual(receivedKinds, ApprovalPayload.Kind.allCasesForTests)
    }

    func testApprovalStateUpdatesExistingMessage() {
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(repository: repository)
        let approval = makeApproval()
        viewModel.sendMessage("Create transfer")
        repository.send(
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
        kind: ApprovalPayload.Kind = .generic
    ) -> ApprovalPayload {
        ApprovalPayload(
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

private extension ApprovalPayload.Kind {
    static let allCasesForTests: [Self] = [
        .currencyConversion,
        .timeDeposit,
        .transfer,
        .savingsPlan
    ]
}
