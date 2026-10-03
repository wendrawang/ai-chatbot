import DesignKit
import TanyaAIData
import TanyaAIDomain
import TanyaAIPresentation

final class TanyaAIDependencyContainer {
    private let configuration: TanyaAIConfiguration
    private let dependencies: TanyaAIDependencies
    var copy: CopyCatalog { configuration.copy }
    var theme: Theme { dependencies.theme }
    var imageLoader: ImageLoading { dependencies.imageLoader }

    init(
        configuration: TanyaAIConfiguration,
        dependencies: TanyaAIDependencies
    ) {
        self.configuration = configuration
        self.dependencies = dependencies
    }

    func makeChatViewModel(isConfirmationEnabled: Bool = false) -> TanyaAIChatViewModel {
        let repository = TanyaAISessionRepository(
            session: dependencies.chatSession
        )
        let useCase = TanyaAIChatUseCase(repository: repository)
        return TanyaAIChatViewModel(
            useCase: useCase,
            isAuthorizationEnabled: dependencies.authorizationService != nil,
            isConfirmationEnabled: isConfirmationEnabled,
            shortcuts: configuration.shortcuts,
            copy: copy
        )
    }

    func makeHistoryViewModel() -> TanyaAIHistoryViewModel {
        TanyaAIHistoryViewModel(items: configuration.historyItems)
    }

    func startInitialPrompt(on viewModel: TanyaAIChatViewModel) {
        guard let initialPrompt = configuration.initialPrompt else {
            return
        }
        viewModel.sendMessage(initialPrompt)
    }

    func makePINViewModel(
        approval: ApprovalPayload
    ) -> TanyaAIPINViewModel? {
        guard let service = dependencies.authorizationService else {
            return nil
        }
        return TanyaAIPINViewModel(
            approval: approval,
            authorizationService: service,
            copy: copy
        )
    }
}
