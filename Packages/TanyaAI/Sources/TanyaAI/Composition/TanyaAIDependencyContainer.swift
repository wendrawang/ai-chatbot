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
        let repository = DefaultTanyaAIRepository(
            transport: dependencies.streamingTransport,
            messagePath: configuration.messagePath
        )
        let useCase = TanyaAIChatUseCase(repository: repository)
        return TanyaAIChatViewModel(useCase: useCase)
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
    ) -> TanyaAIPINViewModel {
        TanyaAIPINViewModel(
            approval: approval,
            authorizationService: dependencies.authorizationService
        )
    }
}
