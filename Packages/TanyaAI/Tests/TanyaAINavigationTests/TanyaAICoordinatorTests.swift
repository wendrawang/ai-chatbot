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

    func testActionReachesTheHostWithoutNavigatingOrOpeningAnything() {
        let navigationController = UINavigationController()
        var received: [TanyaAIAction] = []
        let coordinator = makeCoordinator(
            navigationController: navigationController,
            onAction: { received.append($0) }
        )
        coordinator.start()
        let action = TanyaAIAction(
            identifier: "open-transfer",
            deeplink: "ocbcid://mobile?type=transfer"
        )

        coordinator.handleForTesting(.performAction(action))

        XCTAssertEqual(received, [action])
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssertNil(navigationController.presentedViewController)
    }

    /// A confirmation carrying a hand-off skips the PIN sheet entirely: the
    /// existing screen owns the authorization instead.
    func testApprovalHandoffReportsTheDeeplinkInsteadOfPresentingPIN() {
        let navigationController = UINavigationController()
        var received: [TanyaAIAction] = []
        let coordinator = makeCoordinator(
            navigationController: navigationController,
            onAction: { received.append($0) }
        )
        coordinator.start()
        let handoff = TanyaAIAction(
            identifier: "handoff-transfer",
            deeplink: "ocbcid://mobile?type=transfer"
        )
        var approval = makeApproval(.transfer)
        approval = TanyaAIApprovalPayload(
            approvalIdentifier: approval.approvalIdentifier,
            transactionIdentifier: approval.transactionIdentifier,
            challengeIdentifier: approval.challengeIdentifier,
            kind: approval.kind,
            title: approval.title,
            summary: approval.summary,
            expiresAt: approval.expiresAt,
            handoff: handoff,
            state: .awaitingApproval
        )

        coordinator.chatViewModelForTesting?.approve(approval)

        XCTAssertEqual(received, [handoff])
        XCTAssertNil(navigationController.presentedViewController)
    }

    private func makeCoordinator(
        navigationController: UINavigationController,
        onAction: @escaping (TanyaAIAction) -> Void = { _ in }
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
            containerController: UIViewController(),
            actionHandler: onAction
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
