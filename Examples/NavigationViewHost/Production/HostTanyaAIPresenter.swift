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
/// `ObservableObject` conformance carries no published state. It exists so a
/// host whose screens are built without parameters - a coordinator created as
/// `MainCoordinator()` deep inside a root screen - can reach the presenter
/// through `.environmentObject(...)` instead of threading it down by hand.
/// Injecting an already-built presenter is safe; what must never happen is
/// building the composition inside a `body`.
final class HostTanyaAIPresenter: HostTanyaAIPresenting, ObservableObject {
    private weak var rootController: UIViewController?
    private weak var activeController: UIViewController?

    private let makeDependencies: () -> TanyaAIDependencies
    private let configuration: TanyaAIConfiguration
    private var actionHandler: ((TanyaAIAction) -> Void)?

    /// True while the feature is on screen: a deeplink arriving now has a
    /// dismissal to wait for.
    var isPresenting: Bool {
        activeController != nil
    }

    /// A transport that may be shared between presentations: the host's own
    /// SSE networking holds nothing between requests.
    convenience init(
        dependencies: TanyaAIDependencies,
        configuration: TanyaAIConfiguration = TanyaAIConfiguration()
    ) {
        self.init(configuration: configuration) { dependencies }
    }

    /// A transport that must be rebuilt for each presentation.
    ///
    /// A vendor chat session holds a channel, an event handler, and a
    /// connection. Sharing one instance lets the released graph's `deinit`
    /// clear the handler the new graph just installed - a second chat that
    /// opens normally and then never answers.
    init(
        configuration: TanyaAIConfiguration = TanyaAIConfiguration(),
        makeDependencies: @escaping () -> TanyaAIDependencies
    ) {
        self.configuration = configuration
        self.makeDependencies = makeDependencies
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
            dependencies: makeDependencies(),
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
