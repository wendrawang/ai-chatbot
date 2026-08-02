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
}
