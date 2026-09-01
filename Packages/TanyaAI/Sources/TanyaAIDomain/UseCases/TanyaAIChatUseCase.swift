import TanyaAIContracts

public final class TanyaAIChatUseCase: TanyaAIChatUseCaseProtocol {
    private let repository: TanyaAIRepository

    public init(repository: TanyaAIRepository) {
        self.repository = repository
    }

    @discardableResult
    public func sendMessage(
        conversationIdentifier: String?,
        text: String,
        onEvent: @escaping (TanyaAIStreamEvent) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable {
        repository.sendMessage(
            conversationIdentifier: conversationIdentifier,
            text: text,
            onEvent: onEvent,
            completion: completion
        )
    }

    public func observeUnsolicitedEvents(
        _ onEvent: @escaping (TanyaAIStreamEvent) -> Void
    ) {
        repository.observeUnsolicitedEvents(onEvent)
    }
}
