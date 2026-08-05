import Foundation
import TanyaAIDomain
import TanyaAITestSupport
import UIKit
import XCTest
@testable import TanyaAI

final class TanyaAICoordinatorTests: XCTestCase {
    func testStartCreatesOnlyChatDestination() {
        let navigationController = UINavigationController()
        let coordinator = makeCoordinator(
            navigationController: navigationController
        )

        coordinator.start()

        XCTAssertEqual(navigationController.viewControllers.count, 1)
    }

    func testHistoryIsCreatedOnlyWhenRouteIsRequested() {
        let navigationController = UINavigationController()
        let coordinator = makeCoordinator(
            navigationController: navigationController
        )
        coordinator.start()

        coordinator.show(.history, animated: false)

        XCTAssertEqual(navigationController.viewControllers.count, 2)
    }

    func testEveryConfirmationRoutePresentsPINSheet() {
        let navigationController = UINavigationController()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        let coordinator = makeCoordinator(
            navigationController: navigationController
        )
        coordinator.start()

        confirmationKinds.forEach { kind in
            coordinator.show(.approval(makeApproval(kind)))
            XCTAssertTrue(
                navigationController.presentedViewController
                    is TanyaAIPINSheetViewController
            )
            navigationController.dismiss(animated: false)
        }
        window.isHidden = true
    }

    private func makeCoordinator(
        navigationController: UINavigationController
    ) -> TanyaAICoordinator {
        let dependencies = TanyaAIDependencies(
            streamingTransport: MockTanyaAIStreamingTransport(),
            authorizationService: MockTanyaAIAuthorizationService(),
            theme: .sandbox
        )
        let dependencyContainer = TanyaAIDependencyContainer(
            configuration: TanyaAIConfiguration(),
            dependencies: dependencies
        )
        return TanyaAICoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer,
            containerController: UIViewController()
        )
    }

    private func makeApproval(
        _ kind: TanyaAIApprovalPayload.Kind
    ) -> TanyaAIApprovalPayload {
        TanyaAIApprovalPayload(
            approvalIdentifier: "\(kind.rawValue)-approval",
            transactionIdentifier: "demo-transaction",
            challengeIdentifier: "demo-challenge",
            kind: kind,
            title: "Confirm demo",
            summary: [],
            expiresAt: Date().addingTimeInterval(300),
            state: .awaitingApproval
        )
    }

    private var confirmationKinds: [TanyaAIApprovalPayload.Kind] {
        [.currencyConversion, .timeDeposit, .transfer, .savingsPlan]
    }
}
