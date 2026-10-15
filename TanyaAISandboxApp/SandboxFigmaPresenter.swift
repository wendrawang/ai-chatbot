import DesignKit
import Foundation
import SwiftUI
import TanyaAI
import TanyaAITestSupport
import UIKit

/// Demo-only host routing. Production applications replace these pages with their existing flows.
@MainActor
final class SandboxFigmaPresenter {
    private weak var featureController: UIViewController?
    private var session: MockTanyaAIChatSession?

    func makeFeatureController() -> UIViewController {
        let session = SandboxTanyaAIFactory.figmaSession()
        self.session = session
        let controller = TanyaAIModule.makeViewController(
            configuration: TanyaAIConfiguration(
                copy: SandboxTanyaAIFactory.figmaCopy,
                welcome: SandboxTanyaAIFactory.figmaWelcome
            ),
            dependencies: TanyaAIDependencies(chatSession: session, theme: SandboxTanyaAIFactory.figmaTheme),
            onHostFlow: { [weak self] request, presenter, completion in
                self?.presentHostFlow(request, from: presenter, completion: completion)
            },
            makeNewSession: { [weak self] in
                let replacement = SandboxTanyaAIFactory.figmaSession()
                self?.session = replacement
                return replacement
            },
            onAction: { [weak self] action in self?.openDestination(action) }
        )
        featureController = controller
        return controller
    }

    private func presentHostFlow(
        _ request: TanyaAIHostFlowRequest,
        from presenter: UIViewController,
        completion: @escaping (Result<TanyaAIHostFlowResult, Error>) -> Void
    ) {
        let requestSession = session
        let finish: (TanyaAIHostFlowResult) -> Void = { [weak self, weak presenter, weak requestSession] result in
            presenter?.dismiss(animated: true) {
                completion(.success(result))
                if result.status == .completed, let requestSession, self?.session === requestSession {
                    requestSession.onEvent?(SandboxTanyaAIFactory.resultActions)
                }
            }
        }
        let controller: UIViewController
        if request.kind == .document {
            controller = UIHostingController(
                rootView: DemoHostDocumentScreen(title: request.title, onFinish: finish)
                    .theme(SandboxTanyaAIFactory.figmaTheme)
            )
        } else {
            controller = UIHostingController(
                rootView: DemoHostPINScreen(onFinish: finish)
                    .theme(SandboxTanyaAIFactory.figmaTheme)
                    .copyCatalog(SandboxTanyaAIFactory.figmaCopy)
            )
        }
        controller.modalPresentationStyle = .fullScreen
        presenter.present(controller, animated: true)
    }

    private func openDestination(_ action: TanyaAIAction) {
        guard let presenter = featureController, let url = URL(string: action.deeplink) else { return }
        let close: () -> Void = { [weak presenter] in presenter?.dismiss(animated: true) }
        let controller: UIViewController
        if action.destinationType == .webview, ["https", "http"].contains(url.scheme?.lowercased() ?? "") {
            controller = UIHostingController(
                rootView: DemoHostWebScreen(url: url, onClose: close).theme(SandboxTanyaAIFactory.figmaTheme)
            )
        } else if action.destinationType == .deeplink, url.scheme == "ocbcid", url.host == "mobile" {
            controller = UIHostingController(
                rootView: DemoHostDestinationScreen(url: url, onClose: close).theme(SandboxTanyaAIFactory.figmaTheme)
            )
        } else {
            return
        }
        controller.modalPresentationStyle = .fullScreen
        presenter.present(controller, animated: true)
    }
}
