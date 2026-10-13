import DesignKit
import TanyaAIContracts
import TanyaAIData
import TanyaAIDomain
import TanyaAIPresentation

@MainActor
final class TanyaAIDependencyContainer {
    private let configuration: TanyaAIConfiguration
    private let dependencies: TanyaAIDependencies
    var copy: CopyCatalog { configuration.copy }
    var theme: Theme { dependencies.theme }
    var imageLoader: ImageLoading { dependencies.imageLoader }
    var defaultSession: TanyaAIChatSession { dependencies.chatSession }

    init(
        configuration: TanyaAIConfiguration,
        dependencies: TanyaAIDependencies
    ) {
        self.configuration = configuration
        self.dependencies = dependencies
    }

    func makeChatViewModel(
        isConfirmationEnabled: Bool = false,
        isHostFlowEnabled: Bool = false,
        isNewSessionEnabled: Bool = false,
        session: TanyaAIChatSession? = nil
    ) -> TanyaAIChatViewModel {
        let repository = TanyaAISessionRepository(
            session: session ?? dependencies.chatSession
        )
        return TanyaAIChatViewModel(
            repository: repository,
            isAuthorizationEnabled: dependencies.authorizationService != nil,
            isConfirmationEnabled: isConfirmationEnabled,
            isHostFlowEnabled: isHostFlowEnabled,
            isNewSessionEnabled: isNewSessionEnabled,
            shortcuts: configuration.shortcuts,
            copy: copy,
            welcome: configuration.welcome
        )
    }

    var historyItems: [ConversationSummary] { configuration.historyItems }

    func startInitialPrompt(on viewModel: TanyaAIChatViewModel) {
        guard let initialPrompt = configuration.initialPrompt else {
            return
        }
        viewModel.startInitialPrompt(initialPrompt)
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
