import Foundation
import TanyaAI
import UIKit

/// The whole hand-off, in one type.
///
/// Assumes what most apps already have: a deeplink handler that takes a URL,
/// returns to the dashboard, and opens the destination. If yours does that,
/// there is nothing to build - only something to sequence.
final class MinimalDeeplinkHandoff {
    private weak var rootController: UIViewController?
    private weak var activeController: UIViewController?
    private let dependencies: TanyaAIDependencies

    init(dependencies: TanyaAIDependencies) {
        self.dependencies = dependencies
    }

    func attach(rootController: UIViewController) {
        self.rootController = rootController
    }

    func presentTanyaAI() {
        guard activeController == nil, let rootController else {
            return
        }
        let controller = TanyaAIModule.makeViewController(
            dependencies: dependencies,
            onAction: { [weak self] action in
                self?.handle(action)
            }
        )
        activeController = controller
        rootController.present(controller, animated: true)
    }

    /// Runs when a bubble hands over a deeplink.
    ///
    /// Two checks - the scheme and the entry host - are enough to reject
    /// `https://…`, `tel:`, and links into other apps. What the link means
    /// beyond that is your existing handler's job.
    ///
    /// The navigation waits for the dismissal to finish: a destination opened
    /// while the modal is still animating away is lost.
    private func handle(_ action: TanyaAIAction) {
        guard let url = URL(string: action.deeplink),
              url.scheme == "ocbcid",
              url.host == "mobile" else {
            return
        }
        let controller = activeController
        activeController = nil
        controller?.dismiss(animated: true) {
            AppDeeplinkHandler.open(url)
        }
    }
}

/// The deeplink entry point your app already has - the one your
/// `SceneDelegate` calls from `scene(_:openURLContexts:)`.
///
/// Replace this with the real one.
enum AppDeeplinkHandler {
    static func open(_ url: URL) {}
}
