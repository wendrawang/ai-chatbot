import Foundation
import TanyaAIContracts
import TanyaAIDomain
@testable import TanyaAIPresentation

/// Stands in for the use case across the presentation tests: holds the
/// turn open so each event can be delivered by hand.
final class TanyaAIChatUseCaseStub: TanyaAIChatUseCaseProtocol {
    private var eventHandler: ((TanyaAIStreamEvent) -> Void)?
    private var unsolicitedHandler: ((TanyaAIStreamEvent) -> Void)?
    private var completionHandler: ((Result<Void, Error>) -> Void)?
    private(set) var receivedText: String?

    func sendMessage(
        conversationIdentifier: String?,
        text: String,
        onEvent: @escaping (TanyaAIStreamEvent) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable {
        receivedText = text
        eventHandler = onEvent
        completionHandler = completion
        return TanyaAINoOpCancellable()
    }

    func observeUnsolicitedEvents(
        _ onEvent: @escaping (TanyaAIStreamEvent) -> Void
    ) {
        unsolicitedHandler = onEvent
    }

    func send(_ event: TanyaAIStreamEvent) {
        eventHandler?(event)
    }

    /// A reply that belongs to no turn - a bot greeting, an agent message.
    func sendUnsolicited(_ event: TanyaAIStreamEvent) {
        unsolicitedHandler?(event)
    }

    func complete(_ result: Result<Void, Error>) {
        completionHandler?(result)
    }
}
