import TanyaAIContracts

public protocol TanyaAIChatUseCaseProtocol: AnyObject {
    @discardableResult
    func sendMessage(
        conversationIdentifier: String?,
        text: String,
        onEvent: @escaping (TanyaAIStreamEvent) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable

    func observeUnsolicitedEvents(
        _ onEvent: @escaping (TanyaAIStreamEvent) -> Void
    )

    func updateContext(_ context: TanyaAIContext?)
}

public extension TanyaAIChatUseCaseProtocol {
    func observeUnsolicitedEvents(
        _ onEvent: @escaping (TanyaAIStreamEvent) -> Void
    ) {}

    func updateContext(_ context: TanyaAIContext?) {}
}
