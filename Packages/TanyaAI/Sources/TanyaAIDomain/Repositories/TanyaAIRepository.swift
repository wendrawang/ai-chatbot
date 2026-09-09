import TanyaAIContracts

public protocol TanyaAIRepository: AnyObject {
    @discardableResult
    func sendMessage(
        conversationIdentifier: String?,
        text: String,
        onEvent: @escaping (TanyaAIStreamEvent) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable

    /// Replies that belong to no turn: a bot greeting first, an agent
    /// reaching out, a card pushed by the channel.
    ///
    /// A request-shaped backend never produces these, so the default does
    /// nothing.
    func observeUnsolicitedEvents(
        _ onEvent: @escaping (TanyaAIStreamEvent) -> Void
    )
}

public extension TanyaAIRepository {
    func observeUnsolicitedEvents(
        _ onEvent: @escaping (TanyaAIStreamEvent) -> Void
    ) {}
}
