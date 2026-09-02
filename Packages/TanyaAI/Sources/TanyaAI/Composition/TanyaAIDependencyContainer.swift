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
        let useCase = TanyaAIChatUseCase(repository: makeRepository())
        return TanyaAIChatViewModel(
            useCase: useCase,
            context: configuration.context
        )
    }

    /// One transport per graph. A vendor session wins when both are somehow
    /// present, and an empty `TanyaAIDependencies` cannot be built at all
    /// because both initializers require one.
    private func makeRepository() -> TanyaAIRepository {
        if let session = dependencies.chatSession {
            return TanyaAISessionRepository(
                session: session,
                context: configuration.context
            )
        }
        guard let transport = dependencies.streamingTransport else {
            return TanyaAIUnavailableRepository()
        }
        return DefaultTanyaAIRepository(
            transport: transport,
            messagePath: configuration.messagePath,
            context: configuration.context
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
    ) -> TanyaAIPINViewModel {
        TanyaAIPINViewModel(
            approval: approval,
            authorizationService: dependencies.authorizationService
        )
    }
}
