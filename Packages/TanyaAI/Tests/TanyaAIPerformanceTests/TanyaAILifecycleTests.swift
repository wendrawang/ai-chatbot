import Foundation
import SwiftUI
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
            let featureView = TanyaAIModule.makeView(
                dependencies: makeDependencies()
            )
            var controller: UIViewController? = UIHostingController(
                rootView: featureView
            )
            controller?.loadViewIfNeeded()
            weakController = controller
            controller = nil
        }

        XCTAssertNil(weakController)
    }

    func testRouterReleasesChatAndAuthorizationGraph() {
        weak var weakRouter: TanyaAIRouter?
        weak var weakChatViewModel: TanyaAIChatViewModel?
        weak var weakPINViewModel: TanyaAIPINViewModel?

        autoreleasepool {
            let container = TanyaAIDependencyContainer(
                configuration: TanyaAIConfiguration(),
                dependencies: makeDependencies()
            )
            var router: TanyaAIRouter? = TanyaAIRouter(
                dependencyContainer: container,
                closeHandler: {}
            )
            router?.handle(.requestApproval(makeApproval()))
            weakRouter = router
            weakChatViewModel = router?.chatViewModel
            weakPINViewModel = router?.authorizationSheet?.viewModel
            router = nil
        }

        XCTAssertNil(weakRouter)
        XCTAssertNil(weakChatViewModel)
        XCTAssertNil(weakPINViewModel)
    }

    func testViewModelAndFiveThousandMessagesReleaseTogether() {
        let useCase = TanyaAIChatUseCaseFixture()
        weak var weakViewModel: TanyaAIChatViewModel?
        weak var weakFirstMessage: TanyaAIMessageItemViewModel?
        weak var weakLastMessage: TanyaAIMessageItemViewModel?

        autoreleasepool {
            var viewModel: TanyaAIChatViewModel? = TanyaAIChatViewModel(
                useCase: useCase
            )
            viewModel?.sendMessage("stress fixture")
            useCase.appendStatusMessages(count: 5_000)
            weakViewModel = viewModel
            weakFirstMessage = viewModel?.messages.first
            weakLastMessage = viewModel?.messages.last
            viewModel = nil
        }

        XCTAssertNil(weakViewModel)
        XCTAssertNil(weakFirstMessage)
        XCTAssertNil(weakLastMessage)
        XCTAssertTrue(useCase.cancellationProbe.isCancelled)
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
