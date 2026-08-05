import SwiftUI
import TanyaAIContracts
import TanyaAIDomain
import TanyaAIPresentation
import UIKit

final class TanyaAICoordinator: NSObject {
    private let navigationController: UINavigationController
    private let dependencyContainer: TanyaAIDependencyContainer
    private weak var containerController: UIViewController?
    private weak var chatViewModel: TanyaAIChatViewModel?
    private weak var chatController: UIViewController?

    init(
        navigationController: UINavigationController,
        dependencyContainer: TanyaAIDependencyContainer,
        containerController: UIViewController
    ) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
        self.containerController = containerController
        super.init()
        navigationController.delegate = self
    }

    func start() {
        show(.chat, animated: false)
    }

    func show(_ route: TanyaAIRoute, animated: Bool = true) {
        switch route {
        case .chat:
            showChat()
        case .history:
            showHistory(animated: animated)
        case .approval(let payload):
            showApproval(payload)
        }
    }

    private func showChat() {
        let viewModel = dependencyContainer.makeChatViewModel()
        viewModel.onOutput = { [weak self] output in
            self?.handle(output)
        }
        let controller = UIHostingController(
            rootView: TanyaAIChatView(viewModel: viewModel)
                .tanyaAITheme(dependencyContainer.theme)
        )
        chatViewModel = viewModel
        chatController = controller
        navigationController.setViewControllers(
            [controller],
            animated: false
        )
        dependencyContainer.startInitialPrompt(on: viewModel)
    }

    private func showHistory(animated: Bool) {
        let viewModel = dependencyContainer.makeHistoryViewModel()
        let controller = UIHostingController(
            rootView: TanyaAIHistoryView(viewModel: viewModel)
                .tanyaAITheme(dependencyContainer.theme)
        )
        navigationController.pushViewController(
            controller,
            animated: animated
        )
    }

    private func showApproval(_ payload: TanyaAIApprovalPayload) {
        let viewModel = dependencyContainer.makePINViewModel(
            approval: payload
        )
        viewModel.onOutput = { [weak self, weak viewModel] output in
            self?.handlePIN(output, approval: payload)
            viewModel?.clearSensitiveState()
        }
        let controller = TanyaAIPINSheetViewController(
            viewModel: viewModel,
            theme: dependencyContainer.theme
        )
        controller.isModalInPresentation = true
        navigationController.present(controller, animated: true)
    }

    private func handle(_ output: TanyaAIChatOutput) {
        switch output {
        case .close:
            containerController?.dismiss(animated: true)
        case .openHistory:
            show(.history)
        case .requestApproval(let payload):
            show(.approval(payload))
        }
    }

    private func handlePIN(
        _ output: TanyaAIPINOutput,
        approval: TanyaAIApprovalPayload
    ) {
        switch output {
        case .started:
            updateApproval(approval, state: .authorizing)
        case .cancel:
            navigationController.dismiss(animated: true)
            updateApproval(approval, state: .awaitingApproval)
        case .completed(let result):
            navigationController.dismiss(animated: true)
            let state: TanyaAIApprovalPayload.State =
                result.status == .completed ? .completed : .processing
            updateApproval(approval, state: state)
        }
    }

    private func updateApproval(
        _ approval: TanyaAIApprovalPayload,
        state: TanyaAIApprovalPayload.State
    ) {
        chatViewModel?.updateApproval(
            identifier: approval.approvalIdentifier,
            state: state
        )
    }
}

extension TanyaAICoordinator: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        let showsChat = viewController === chatController
        navigationController.setNavigationBarHidden(showsChat, animated: animated)
    }
}
