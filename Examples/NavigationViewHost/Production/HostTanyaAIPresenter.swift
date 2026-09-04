import TanyaAI
import UIKit

/// What the existing screens and coordinators depend on.
///
/// Legacy screens stay unaware of Tanya AI: they only ask the presenter to
/// open or close the feature.
protocol HostTanyaAIPresenting: AnyObject {
    func presentTanyaAI()
    func dismissTanyaAI()
}

/// Presents the feature from the host's own view controller.
///
/// It holds a presentation, not a feature graph: `makeViewController` is
/// called per presentation, so each session gets its own controller, router,
/// ViewModels, and stream.
final class HostTanyaAIPresenter: HostTanyaAIPresenting {
    private weak var rootController: UIViewController?
    private weak var activeController: UIViewController?

    private let dependencies: TanyaAIDependencies
    private let configuration: TanyaAIConfiguration
    private var actionHandler: ((TanyaAIAction) -> Void)?

    /// True while the feature is on screen: a deeplink arriving now has a
    /// dismissal to wait for.
    var isPresenting: Bool {
        activeController != nil
    }

    init(
        dependencies: TanyaAIDependencies,
        configuration: TanyaAIConfiguration = TanyaAIConfiguration()
    ) {
        self.dependencies = dependencies
        self.configuration = configuration
    }

    /// The controller the feature is presented from - usually the hosting
    /// controller of your root screen.
    func attach(rootController: UIViewController) {
        self.rootController = rootController
    }

    /// Registers what happens when a bubble hands a deeplink to the host.
    func onAction(_ handler: @escaping (TanyaAIAction) -> Void) {
        actionHandler = handler
    }

    func presentTanyaAI() {
        guard activeController == nil,
              let rootController,
              rootController.presentedViewController == nil else {
            return
        }
        let controller = TanyaAIModule.makeViewController(
            configuration: configuration,
            dependencies: dependencies,
            onAction: { [weak self] action in
                self?.actionHandler?(action)
            }
        )
        activeController = controller
        rootController.present(controller, animated: true)
    }

    func dismissTanyaAI() {
        dismissTanyaAI(completion: nil)
    }

    /// Closes the feature and reports when the screen is actually clear.
    ///
    /// The completion is what makes a deeplink hand-off correct: a destination
    /// opened while the modal is still animating away is lost.
    func dismissTanyaAI(completion: (() -> Void)?) {
        guard let controller = activeController else {
            completion?()
            return
        }
        activeController = nil
        controller.dismiss(animated: true, completion: completion)
    }
}
