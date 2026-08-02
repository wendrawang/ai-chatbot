import TanyaAI
import UIKit

final class TanyaAIPresentationGateway: TanyaAIPresenting {
    private weak var rootController: UIViewController?
    private weak var activeController: UIViewController?

    private let dependencies: TanyaAIDependencies
    private let configuration: TanyaAIConfiguration

    init(
        dependencies: TanyaAIDependencies,
        configuration: TanyaAIConfiguration
    ) {
        self.dependencies = dependencies
        self.configuration = configuration
    }

    func attach(rootController: UIViewController) {
        self.rootController = rootController
    }

    func presentTanyaAI() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.presentTanyaAI()
            }
            return
        }
        guard activeController == nil else {
            return
        }
        guard let rootController = rootController else {
            return
        }
        guard rootController.presentedViewController == nil else {
            return
        }

        let viewController = TanyaAIModule.makeViewController(
            configuration: configuration,
            dependencies: dependencies
        )
        activeController = viewController
        rootController.present(viewController, animated: true)
    }

    func dismissTanyaAI() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.dismissTanyaAI()
            }
            return
        }
        activeController?.dismiss(animated: true)
    }
}
