import Combine
import TanyaAIDomain
import TanyaAIPresentation

final class TanyaAIRouter: ObservableObject {
    @Published var path: [TanyaAIRoute] = []
    @Published var authorizationSheet: TanyaAIAuthorizationSheet?

    let chatViewModel: TanyaAIChatViewModel

    private let dependencyContainer: TanyaAIDependencyContainer
    private let closeHandler: () -> Void
    private let actionHandler: (TanyaAIAction) -> Void
    private var activeApproval: TanyaAIApprovalPayload?
    private weak var activePINViewModel: TanyaAIPINViewModel?
    private var hasStarted = false

    private lazy var cachedHistoryViewModel =
        dependencyContainer.makeHistoryViewModel()

    init(
        dependencyContainer: TanyaAIDependencyContainer,
        closeHandler: @escaping () -> Void,
        actionHandler: @escaping (TanyaAIAction) -> Void = { _ in }
    ) {
        self.dependencyContainer = dependencyContainer
        self.closeHandler = closeHandler
        self.actionHandler = actionHandler
        chatViewModel = dependencyContainer.makeChatViewModel()
        chatViewModel.onOutput = { [weak self] output in
            self?.handle(output)
        }
    }

    var historyViewModel: TanyaAIHistoryViewModel {
        cachedHistoryViewModel
    }

    func startIfNeeded() {
        guard !hasStarted else {
            return
        }
        hasStarted = true
        dependencyContainer.startInitialPrompt(on: chatViewModel)
    }

    func handle(_ output: TanyaAIChatOutput) {
        switch output {
        case .close:
            closeHandler()
        case .openHistory:
            path.append(.history)
        case .requestApproval(let approval):
            presentAuthorization(for: approval)
        case .performAction(let action):
            actionHandler(action)
        }
    }

    func authorizationSheetDidDismiss() {
        guard let approval = activeApproval else {
            return
        }
        releaseAuthorization()
        updateApproval(approval, state: .awaitingApproval)
    }

    deinit {
        chatViewModel.onOutput = nil
        activePINViewModel?.onOutput = nil
        activePINViewModel?.clearSensitiveState()
    }

    private func presentAuthorization(
        for approval: TanyaAIApprovalPayload
    ) {
        let viewModel = dependencyContainer.makePINViewModel(
            approval: approval
        )
        viewModel.onOutput = { [weak self, weak viewModel] output in
            self?.handlePIN(output, approval: approval)
            viewModel?.clearSensitiveState()
        }
        activeApproval = approval
        activePINViewModel = viewModel
        authorizationSheet = TanyaAIAuthorizationSheet(
            approval: approval,
            viewModel: viewModel
        )
    }

    private func handlePIN(
        _ output: TanyaAIPINOutput,
        approval: TanyaAIApprovalPayload
    ) {
        switch output {
        case .started:
            updateApproval(approval, state: .authorizing)
        case .cancel:
            releaseAuthorization()
            updateApproval(approval, state: .awaitingApproval)
        case .completed(let result):
            let state: TanyaAIApprovalPayload.State =
                result.status == .completed ? .completed : .processing
            updateApproval(approval, state: state)
            releaseAuthorization()
        }
    }

    private func releaseAuthorization() {
        activePINViewModel?.onOutput = nil
        activePINViewModel?.clearSensitiveState()
        activePINViewModel = nil
        activeApproval = nil
        authorizationSheet = nil
    }

    private func updateApproval(
        _ approval: TanyaAIApprovalPayload,
        state: TanyaAIApprovalPayload.State
    ) {
        chatViewModel.updateApproval(
            identifier: approval.approvalIdentifier,
            state: state
        )
    }
}
