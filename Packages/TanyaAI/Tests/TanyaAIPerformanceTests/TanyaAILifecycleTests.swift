import Foundation
import TanyaAIDomain
import TanyaAITestSupport
import UIKit
import XCTest
@testable import TanyaAI
@testable import TanyaAIPresentation

final class TanyaAILifecycleTests: XCTestCase {
    func testChatViewModelReleasesAndCancelsActiveRequest() {
        let useCase = TanyaAIChatUseCaseFixture()
        weak var weakViewModel: TanyaAIChatViewModel?

        autoreleasepool {
            var viewModel: TanyaAIChatViewModel? = TanyaAIChatViewModel(
                useCase: useCase
            )
            viewModel?.sendMessage("performance fixture")
            weakViewModel = viewModel
            viewModel = nil
        }

        XCTAssertNil(weakViewModel)
        XCTAssertTrue(useCase.cancellationProbe.isCancelled)
    }

    func testPINViewModelReleasesAndCancelsActiveRequest() {
        let authorizationService = TanyaAIAuthorizationFixture()
        weak var weakViewModel: TanyaAIPINViewModel?

        autoreleasepool {
            var viewModel: TanyaAIPINViewModel? = TanyaAIPINViewModel(
                approval: makeApproval(),
                authorizationService: authorizationService
            )
            [1, 2, 3, 4, 5, 6].forEach {
                viewModel?.appendDigit($0)
            }
            weakViewModel = viewModel
            viewModel = nil
        }

        XCTAssertNil(weakViewModel)
        XCTAssertTrue(authorizationService.cancellationProbe.isCancelled)
    }

    func testCompleteFeatureGraphReleasesAfterDismissal() {
        weak var weakController: UIViewController?

        autoreleasepool {
            var controller: UIViewController? = TanyaAIModule.makeViewController(
                dependencies: makeDependencies()
            )
            controller?.loadViewIfNeeded()
            weakController = controller
            controller = nil
        }

        XCTAssertNil(weakController)
    }

    private func makeApproval() -> TanyaAIApprovalPayload {
        TanyaAIApprovalPayload(
            approvalIdentifier: "approval-fixture",
            transactionIdentifier: "transaction-fixture",
            challengeIdentifier: "challenge-fixture",
            title: "Sample approval",
            summary: [],
            expiresAt: Date().addingTimeInterval(300),
            state: .awaitingApproval
        )
    }

    private func makeDependencies() -> TanyaAIDependencies {
        TanyaAIDependencies(
            streamingTransport: MockTanyaAIStreamingTransport(),
            authorizationService: MockTanyaAIAuthorizationService(),
            theme: .sandbox
        )
    }
}
