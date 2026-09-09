import TanyaAI
import UIKit

final class TanyaAIPresentationGateway: TanyaAIPresenting {
    private weak var rootController: UIViewController?
    private weak var activeController: UIViewController?

    private let dependencies: TanyaAIDependencies
    private let configuration: TanyaAIConfiguration
    private var actionHandler: ((TanyaAIAction) -> Void)?

    /// True while the feature is on screen. The deeplink router needs to know
    /// whether there is a dismissal to wait for.
    var isPresenting: Bool {
        activeController != nil
    }

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

    /// Registers what happens when a bubble hands a deeplink to the host.
    /// Set once by the scene; the gateway itself does not interpret it.
    func onAction(_ handler: @escaping (TanyaAIAction) -> Void) {
        actionHandler = handler
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
            dependencies: dependencies,
            onAction: { [weak self] action in
                self?.actionHandler?(action)
            }
        )
        activeController = viewController
        rootController.present(viewController, animated: true)
    }

    func dismissTanyaAI() {
        dismissTanyaAI(completion: nil)
    }

    /// Closes the feature and reports when the screen is actually clear.
    ///
    /// The completion is what makes the deeplink hand-off correct: a
    /// destination pushed while the modal is still animating away is lost.
    func dismissTanyaAI(completion: (() -> Void)?) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.dismissTanyaAI(completion: completion)
            }
            return
        }
        guard let controller = activeController else {
            completion?()
            return
        }
        activeController = nil
        controller.dismiss(animated: true, completion: completion)
    }
}
