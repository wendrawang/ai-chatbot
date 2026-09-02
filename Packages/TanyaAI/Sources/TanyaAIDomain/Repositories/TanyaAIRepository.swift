import TanyaAIContracts

public protocol TanyaAIRepository: AnyObject {
    @discardableResult
    func sendMessage(
        conversationIdentifier: String?,
        text: String,
        onEvent: @escaping (TanyaAIStreamEvent) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable

    /// Events that arrive outside a turn, such as an agent replying on their
    /// own. Only a session transport produces them, so the default does
    /// nothing and the SSE repository stays unchanged.
    func observeUnsolicitedEvents(
        _ onEvent: @escaping (TanyaAIStreamEvent) -> Void
    )

    /// Replaces the context sent with subsequent messages. Nil clears it,
    /// which is what the customer dismissing the context chip means.
    func updateContext(_ context: TanyaAIContext?)
}

public extension TanyaAIRepository {
    func observeUnsolicitedEvents(
        _ onEvent: @escaping (TanyaAIStreamEvent) -> Void
    ) {}

    func updateContext(_ context: TanyaAIContext?) {}
}
