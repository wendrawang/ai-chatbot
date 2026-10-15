import DesignKit
import TanyaAIContracts
import TanyaAIData
import TanyaAIPresentation

@MainActor
final class TanyaAIDependencyContainer {
    private let configuration: TanyaAIConfiguration
    private let dependencies: TanyaAIDependencies
    var copy: CopyCatalog { configuration.copy }
    var theme: Theme { dependencies.theme }
    var defaultSession: TanyaAIChatSession { dependencies.chatSession }

    init(configuration: TanyaAIConfiguration, dependencies: TanyaAIDependencies) {
        self.configuration = configuration
        self.dependencies = dependencies
    }

    func makeChatViewModel(
        isHostFlowEnabled: Bool = false,
        isNewSessionEnabled: Bool = false,
        session: TanyaAIChatSession? = nil
    ) -> TanyaAIChatViewModel {
        TanyaAIChatViewModel(
            repository: TanyaAISessionRepository(session: session ?? dependencies.chatSession),
            isHostFlowEnabled: isHostFlowEnabled,
            isNewSessionEnabled: isNewSessionEnabled,
            copy: copy,
            welcome: configuration.welcome
        )
    }

    func startInitialPrompt(on viewModel: TanyaAIChatViewModel) {
        guard let initialPrompt = configuration.initialPrompt else { return }
        viewModel.startInitialPrompt(initialPrompt)
    }
}
