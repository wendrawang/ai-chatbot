import DesignKit
import SwiftUI
import TanyaAIContracts
import TanyaAIDomain
import TanyaAIPresentation
import UIKit

@MainActor
final class TanyaAICoordinator: NSObject {
    private let navigationController: UINavigationController
    private let dependencyContainer: TanyaAIDependencyContainer
    private weak var containerController: UIViewController?
    private let actionHandler: (Action) -> Void
    private let hostFlowHandler: TanyaAIHostFlowHandler?
    private let makeNewSession: (() -> TanyaAIChatSession)?
    private weak var chatViewModel: TanyaAIChatViewModel?
    private weak var chatController: UIViewController?
    private weak var currentSession: TanyaAIChatSession?

    init(
        navigationController: UINavigationController,
        dependencyContainer: TanyaAIDependencyContainer,
        containerController: UIViewController,
        actionHandler: @escaping (Action) -> Void = { _ in },
        hostFlowHandler: TanyaAIHostFlowHandler? = nil,
        makeNewSession: (() -> TanyaAIChatSession)? = nil
    ) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
        self.containerController = containerController
        self.actionHandler = actionHandler
        self.hostFlowHandler = hostFlowHandler
        self.makeNewSession = makeNewSession
        super.init()
        navigationController.delegate = self
    }

    func start() {
        showChat()
    }

    private func showChat(session: TanyaAIChatSession? = nil, isInitialPromptEnabled: Bool = true) {
        let session = session ?? dependencyContainer.defaultSession
        let viewModel = dependencyContainer.makeChatViewModel(
            isHostFlowEnabled: hostFlowHandler != nil,
            isNewSessionEnabled: makeNewSession != nil,
            session: session
        )
        viewModel.onOutput = { [weak self] output in
            self?.handle(output)
        }
        let controller = UIHostingController(
            rootView: ChatScreen(viewModel: viewModel)
                .theme(dependencyContainer.theme)
                .copyCatalog(dependencyContainer.copy)
        )
        chatViewModel = viewModel
        chatController = controller
        currentSession = session
        navigationController.setViewControllers(
            [controller],
            animated: false
        )
        if isInitialPromptEnabled { dependencyContainer.startInitialPrompt(on: viewModel) }
    }

    private func handle(_ output: TanyaAIChatOutput) {
        switch output {
        case .close:
            containerController?.dismiss(animated: true)
        case .requestHostFlow(let request):
            requestHostFlow(request)
        case .startNewSession:
            startNewSession()
        case .performAction(let action):
            actionHandler(action)
        }
    }

    private func startNewSession() {
        guard let makeNewSession, navigationController.presentedViewController == nil else { return }
        let session = makeNewSession()
        guard session !== currentSession else { return }
        chatController?.view.endEditing(true)
        showChat(session: session, isInitialPromptEnabled: false)
    }

    private func requestHostFlow(_ request: TanyaAIHostFlowRequest) {
        guard let hostFlowHandler, let viewModel = chatViewModel, let presenter = chatController else { return }
        hostFlowHandler(request, presenter) { [weak self, weak viewModel] result in
            DispatchQueue.main.async { [weak self, weak viewModel] in
                guard let self, let viewModel, self.chatViewModel === viewModel else { return }
                viewModel.completeHostFlow(requestIdentifier: request.identifier, result: result)
            }
        }
    }

}

#if DEBUG
    extension TanyaAICoordinator {
        /// Test seam: the chat's own output path, without a rendered view.
        func handleForTesting(_ output: TanyaAIChatOutput) {
            handle(output)
        }

        var chatViewModelForTesting: TanyaAIChatViewModel? {
            chatViewModel
        }
    }
#endif

extension TanyaAICoordinator: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated isAnimated: Bool
    ) {
        let isChatVisible = viewController === chatController
        navigationController.setNavigationBarHidden(isChatVisible, animated: isAnimated)
    }
}
