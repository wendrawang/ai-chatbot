import DesignKit
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
        return TanyaAIChatViewModel(
            repository: repository,
            isAuthorizationEnabled: dependencies.authorizationService != nil,
            isConfirmationEnabled: isConfirmationEnabled,
            shortcuts: configuration.shortcuts,
            copy: copy
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
