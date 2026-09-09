import Foundation
import TanyaAIContracts
import TanyaAIDomain
import XCTest
@testable import TanyaAIPresentation

/// A confirmation the customer already closed is a record of what happened.
/// Nothing may edit it afterwards - not a repeated message from the backend,
/// and not a late callback from a sheet that was already dismissed.
final class TanyaAIApprovalBubbleTests: XCTestCase {
    func testRepeatedApprovalOpensANewBubbleInsteadOfReopeningTheOldOne() {
        let useCase = UseCaseStub()
        let viewModel = makeViewModel(useCase: useCase)

        useCase.send(approvalEvent())
        viewModel.cancelApproval(makeApproval())
        useCase.send(approvalEvent())

        let approvals = approvalPayloads(in: viewModel)
        XCTAssertEqual(approvals.count, 2)
        XCTAssertEqual(approvals[0].state, .cancelled)
        XCTAssertEqual(approvals[1].state, .awaitingApproval)
    }

    /// The reopened bubble is the one that receives further state, so
    /// authorizing the new request cannot alter the cancelled record.
    func testStateUpdatesReachTheNewBubbleOnly() {
        let useCase = UseCaseStub()
        let viewModel = makeViewModel(useCase: useCase)

        useCase.send(approvalEvent())
        viewModel.cancelApproval(makeApproval())
        useCase.send(approvalEvent())
        viewModel.updateApproval(
            identifier: "approval-demo",
            state: .completed
        )

        let approvals = approvalPayloads(in: viewModel)
        XCTAssertEqual(approvals[0].state, .cancelled)
        XCTAssertEqual(approvals[1].state, .completed)
    }

    /// A PIN sheet dismissed after the customer already cancelled must not
    /// revive the confirmation.
    func testSettledApprovalIgnoresLateStateUpdates() {
        let useCase = UseCaseStub()
        let viewModel = makeViewModel(useCase: useCase)

        useCase.send(approvalEvent())
        viewModel.cancelApproval(makeApproval())
        viewModel.updateApproval(
            identifier: "approval-demo",
            state: .awaitingApproval
        )

        XCTAssertEqual(approvalPayloads(in: viewModel).map(\.state), [.cancelled])
    }

    /// The guard is specific to settled approvals: an in-flight one still
    /// updates in place rather than growing a second bubble.
    func testApprovalStillUpdatesInPlaceWhileItIsOpen() {
        let useCase = UseCaseStub()
        let viewModel = makeViewModel(useCase: useCase)

        useCase.send(approvalEvent())
        useCase.send(approvalEvent())

        XCTAssertEqual(approvalPayloads(in: viewModel).count, 1)
    }

    /// Text is streamed, not sent as one content event, so the delta path
    /// needs the same guard: a reply about the cancelled transfer must not
    /// overwrite the record of it.
    func testTextDeltaAfterASettledApprovalOpensANewBubble() {
        let useCase = UseCaseStub()
        let viewModel = makeViewModel(useCase: useCase)

        useCase.send(approvalEvent())
        viewModel.cancelApproval(makeApproval())
        useCase.send(
            .textDelta(messageIdentifier: "approval-card", text: "Baik, ")
        )
        useCase.send(.responseCompleted(messageIdentifier: "approval-card"))

        XCTAssertEqual(approvalPayloads(in: viewModel).map(\.state), [.cancelled])
        XCTAssertEqual(texts(in: viewModel).last, "Baik, ")
    }

    /// The replacement is remembered, so the rest of the turn lands in the
    /// bubble the first delta opened instead of one bubble per chunk.
    func testFurtherDeltasReachTheReplacementBubble() {
        let useCase = UseCaseStub()
        let viewModel = makeViewModel(useCase: useCase)

        useCase.send(approvalEvent())
        viewModel.cancelApproval(makeApproval())
        useCase.send(
            .textDelta(messageIdentifier: "approval-card", text: "Baik, ")
        )
        useCase.send(.responseCompleted(messageIdentifier: "approval-card"))
        useCase.send(
            .textDelta(messageIdentifier: "approval-card", text: "dibatalkan.")
        )
        useCase.send(.responseCompleted(messageIdentifier: "approval-card"))

        XCTAssertEqual(texts(in: viewModel).last, "Baik, dibatalkan.")
        XCTAssertEqual(viewModel.messages.count, 3)
    }

    // MARK: - Helpers

    /// Opens a turn, which is what registers the event handler.
    private func makeViewModel(
        useCase: UseCaseStub,
        authorizesInFeature: Bool = true
    ) -> TanyaAIChatViewModel {
        let viewModel = TanyaAIChatViewModel(
            useCase: useCase,
            authorizesInFeature: authorizesInFeature
        )
        viewModel.inputText = "konfirmasi"
        viewModel.sendCurrentMessage()
        return viewModel
    }

    /// A host that authorizes nothing in chat injects no service. A
    /// confirmation that would need the PIN sheet must then be refused where
    /// the customer can see it, and the bubble left untouched.
    func testConfirmationIsRefusedWhenNothingCanAuthorizeIt() {
        let useCase = UseCaseStub()
        let viewModel = makeViewModel(
            useCase: useCase,
            authorizesInFeature: false
        )
        var outputs: [TanyaAIChatOutput] = []
        viewModel.onOutput = { outputs.append($0) }

        useCase.send(approvalEvent())
        viewModel.approve(makeApproval())

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(approvalPayloads(in: viewModel).first?.state, .awaitingApproval)
        XCTAssertTrue(outputs.isEmpty)
    }

    /// A hand-off never needs the PIN sheet, so it still leaves for the host.
    func testHandoffStillReachesTheHostWithoutAnAuthorizationService() {
        let useCase = UseCaseStub()
        let viewModel = makeViewModel(
            useCase: useCase,
            authorizesInFeature: false
        )
        var actions: [TanyaAIAction] = []
        viewModel.onOutput = { output in
            if case .performAction(let action) = output {
                actions.append(action)
            }
        }

        viewModel.approve(makeHandoffApproval())

        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(actions.first?.deeplink, "ocbcid://mobile?type=transfer")
    }

    private func makeHandoffApproval() -> TanyaAIApprovalPayload {
        TanyaAIApprovalPayload(
            approvalIdentifier: "approval-handoff",
            transactionIdentifier: "transaction-demo",
            challengeIdentifier: "challenge-demo",
            kind: .transfer,
            title: "Approve demo",
            summary: [],
            expiresAt: Date().addingTimeInterval(300),
            handoff: TanyaAIAction(
                identifier: "handoff-transfer",
                deeplink: "ocbcid://mobile?type=transfer"
            ),
            state: .awaitingApproval
        )
    }

    private func approvalEvent() -> TanyaAIStreamEvent {
        .content(
            messageIdentifier: "approval-card",
            content: .approval(makeApproval())
        )
    }

    private func approvalPayloads(
        in viewModel: TanyaAIChatViewModel
    ) -> [TanyaAIApprovalPayload] {
        viewModel.messages.compactMap { message in
            guard case .approval(let payload) = message.content else {
                return nil
            }
            return payload
        }
    }

    private func texts(
        in viewModel: TanyaAIChatViewModel
    ) -> [String] {
        viewModel.messages.compactMap { message in
            guard case .text(let value) = message.content else {
                return nil
            }
            return value
        }
    }

    private func makeApproval() -> TanyaAIApprovalPayload {
        TanyaAIApprovalPayload(
            approvalIdentifier: "approval-demo",
            transactionIdentifier: "transaction-demo",
            challengeIdentifier: "challenge-demo",
            kind: .transfer,
            title: "Approve demo",
            summary: [],
            expiresAt: Date().addingTimeInterval(300),
            state: .awaitingApproval
        )
    }
}

private final class UseCaseStub: TanyaAIChatUseCaseProtocol {
    private var eventHandler: ((TanyaAIStreamEvent) -> Void)?

    func sendMessage(
        conversationIdentifier: String?,
        text: String,
        onEvent: @escaping (TanyaAIStreamEvent) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable {
        eventHandler = onEvent
        return TanyaAINoOpCancellable()
    }

    func send(_ event: TanyaAIStreamEvent) {
        eventHandler?(event)
    }
}
