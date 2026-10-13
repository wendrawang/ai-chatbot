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
    private let confirmationHandler: ((ConfirmationPayload) -> Void)?
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
        confirmationHandler: ((ConfirmationPayload) -> Void)? = nil,
        hostFlowHandler: TanyaAIHostFlowHandler? = nil,
        makeNewSession: (() -> TanyaAIChatSession)? = nil
    ) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
        self.containerController = containerController
        self.confirmationHandler = confirmationHandler
        self.actionHandler = actionHandler
        self.hostFlowHandler = hostFlowHandler
        self.makeNewSession = makeNewSession
        super.init()
        navigationController.delegate = self
    }

    func start() {
        show(.chat, animated: false)
    }

    func show(_ route: TanyaAIRoute, animated isAnimated: Bool = true) {
        switch route {
        case .chat:
            showChat()
        case .history:
            showHistory(animated: isAnimated)
        case .approval(let payload):
            showApproval(payload)
        }
    }

    private func showChat(session: TanyaAIChatSession? = nil, isInitialPromptEnabled: Bool = true) {
        let session = session ?? dependencyContainer.defaultSession
        let viewModel = dependencyContainer.makeChatViewModel(
            isConfirmationEnabled: confirmationHandler != nil,
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
                .imageLoader(dependencyContainer.imageLoader)
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

    private func showHistory(animated isAnimated: Bool) {
        let controller = UIHostingController(
            rootView: ConversationHistoryScreen(items: dependencyContainer.historyItems)
                .theme(dependencyContainer.theme)
                .copyCatalog(dependencyContainer.copy)
                .imageLoader(dependencyContainer.imageLoader)
        )
        navigationController.pushViewController(
            controller,
            animated: isAnimated
        )
    }

    private func showApproval(_ payload: ApprovalPayload) {
        // Unreachable when no authorization service was injected: the
        // ViewModel refuses the confirmation before it gets here.
        guard
            let viewModel = dependencyContainer.makePINViewModel(
                approval: payload
            )
        else {
            return
        }
        viewModel.onOutput = { [weak self, weak viewModel] output in
            self?.handlePIN(output, approval: payload)
            viewModel?.clearSensitiveState()
        }
        let controller = AuthorizationSheetViewController(
            viewModel: viewModel,
            theme: dependencyContainer.theme,
            copy: dependencyContainer.copy
        )
        controller.isModalInPresentation = true
        navigationController.present(controller, animated: true)
    }

    /// Turns a chat intent into navigation.
    ///
    /// `history` and `approval` stay inside the feature's own stack.
    /// `performAction` leaves the package entirely: it is forwarded to the
    /// host, and the feature neither opens the deeplink nor dismisses itself.
    private func handle(_ output: TanyaAIChatOutput) {
        switch output {
        case .close:
            containerController?.dismiss(animated: true)
        case .openHistory:
            show(.history)
        case .requestApproval(let payload):
            show(.approval(payload))
        case .requestConfirmation(let payload):
            confirmationHandler?(payload)
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

    private func handlePIN(
        _ output: TanyaAIPINOutput,
        approval: ApprovalPayload
    ) {
        switch output {
        case .started:
            updateApproval(approval, state: .authorizing)
        case .cancel:
            navigationController.dismiss(animated: true)
            updateApproval(approval, state: .awaitingApproval)
        case .completed(let result):
            navigationController.dismiss(animated: true)
            let state: ApprovalPayload.State =
                result.status == .completed ? .completed : .processing
            updateApproval(approval, state: state)
        }
    }

    private func updateApproval(
        _ approval: ApprovalPayload,
        state: ApprovalPayload.State
    ) {
        chatViewModel?.updateApproval(
            identifier: approval.approvalIdentifier,
            state: state
        )
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
