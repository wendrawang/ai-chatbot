import Foundation
import TanyaAIContracts
import TanyaAIDomain
import TanyaAITestSupport
import XCTest
@testable import TanyaAIPresentation

final class TanyaAIPINViewModelTests: XCTestCase {
    func testValidDemoPINCompletesAuthorization() {
        let completionExpectation = expectation(description: "authorization completes")
        let service = MockTanyaAIAuthorizationService(
            callbackQueue: .main,
            delay: 0.001
        )
        let viewModel = TanyaAIPINViewModel(
            approval: makeApproval(),
            authorizationService: service
        )
        viewModel.onOutput = { output in
            if case .completed(let result) = output {
                XCTAssertEqual(result.status, .completed)
                completionExpectation.fulfill()
            }
        }

        enterPIN("123456", into: viewModel)

        XCTAssertTrue(viewModel.pin.isEmpty)
        wait(for: [completionExpectation], timeout: 1)
    }

    func testInvalidPINDisplaysError() {
        let failureExpectation = expectation(description: "error appears")
        let service = MockTanyaAIAuthorizationService(
            callbackQueue: .main,
            delay: 0.001
        )
        let viewModel = TanyaAIPINViewModel(
            approval: makeApproval(),
            authorizationService: service
        )
        enterPIN("000000", into: viewModel)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            XCTAssertNotNil(viewModel.errorMessage)
            failureExpectation.fulfill()
        }
        wait(for: [failureExpectation], timeout: 1)
    }

    func testDeleteRemovesLastEnteredDigit() {
        let viewModel = makeViewModel()
        viewModel.appendDigit(1)
        viewModel.appendDigit(2)

        viewModel.deleteLastDigit()

        XCTAssertEqual(viewModel.pin, "1")
    }

    func testIncompletePINCannotSubmit() {
        let viewModel = makeViewModel()
        viewModel.appendDigit(1)

        viewModel.submit()

        XCTAssertEqual(viewModel.errorMessage, "Enter a 6-digit PIN.")
        XCTAssertFalse(viewModel.isSubmitting)
    }

    func testCancelClearsPINAndProducesOutput() {
        let viewModel = makeViewModel()
        var didCancel = false
        viewModel.onOutput = { output in
            if case .cancel = output {
                didCancel = true
            }
        }
        viewModel.appendDigit(1)
        viewModel.appendDigit(2)

        viewModel.cancel()

        XCTAssertTrue(viewModel.pin.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(didCancel)
    }

    func testInputIsLockedDuringSubmission() {
        let service = HoldingAuthorizationService()
        let viewModel = TanyaAIPINViewModel(
            approval: makeApproval(),
            authorizationService: service
        )
        enterPIN("123456", into: viewModel)

        viewModel.appendDigit(7)
        viewModel.deleteLastDigit()
        viewModel.cancel()

        XCTAssertTrue(viewModel.isSubmitting)
        XCTAssertTrue(viewModel.pin.isEmpty)
        XCTAssertFalse(service.cancellable.isCancelled)
    }

    func testInvalidDigitsAreIgnored() {
        let viewModel = makeViewModel()

        viewModel.appendDigit(-1)
        viewModel.appendDigit(10)

        XCTAssertTrue(viewModel.pin.isEmpty)
    }

    private func enterPIN(
        _ pin: String,
        into viewModel: TanyaAIPINViewModel
    ) {
        pin.compactMap { Int(String($0)) }.forEach(viewModel.appendDigit)
    }

    private func makeViewModel() -> TanyaAIPINViewModel {
        TanyaAIPINViewModel(
            approval: makeApproval(),
            authorizationService: MockTanyaAIAuthorizationService()
        )
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

private final class HoldingAuthorizationService:
    TanyaAIAuthorizationService {

    let cancellable = HoldingCancellable()

    func authorize(
        request: TanyaAIAuthorizationRequest,
        pin: String,
        completion: @escaping (
            Result<TanyaAIAuthorizationResult, Error>
        ) -> Void
    ) -> TanyaAICancellable {
        cancellable
    }
}

private final class HoldingCancellable: TanyaAICancellable {
    private(set) var isCancelled = false

    func cancel() {
        isCancelled = true
    }
}
