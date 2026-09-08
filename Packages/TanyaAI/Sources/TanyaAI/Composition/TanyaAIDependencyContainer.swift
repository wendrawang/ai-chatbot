import TanyaAIData
import TanyaAIDomain
import TanyaAIPresentation

final class TanyaAIDependencyContainer {
    private let configuration: TanyaAIConfiguration
    private let dependencies: TanyaAIDependencies
    var theme: TanyaAITheme { dependencies.theme }

    init(
        configuration: TanyaAIConfiguration,
        dependencies: TanyaAIDependencies
    ) {
        self.configuration = configuration
        self.dependencies = dependencies
    }

    func makeChatViewModel() -> TanyaAIChatViewModel {
        let repository = TanyaAISessionRepository(
            session: dependencies.chatSession
        )
        let useCase = TanyaAIChatUseCase(repository: repository)
        return TanyaAIChatViewModel(
            useCase: useCase,
            authorizesInFeature: dependencies.authorizationService != nil
        )
    }

    func makeHistoryViewModel() -> TanyaAIHistoryViewModel {
        TanyaAIHistoryViewModel()
    }

    func startInitialPrompt(on viewModel: TanyaAIChatViewModel) {
        guard let initialPrompt = configuration.initialPrompt else {
            return
        }
        viewModel.sendMessage(initialPrompt)
    }

    func makePINViewModel(
        approval: TanyaAIApprovalPayload
    ) -> TanyaAIPINViewModel? {
        guard let service = dependencies.authorizationService else {
            return nil
        }
        return TanyaAIPINViewModel(
            approval: approval,
            authorizationService: service
        )
    }
}
