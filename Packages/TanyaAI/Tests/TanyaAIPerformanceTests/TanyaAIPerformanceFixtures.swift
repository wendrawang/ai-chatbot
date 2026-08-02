import Foundation
import TanyaAIContracts
import TanyaAIDomain

final class TanyaAICancellationProbe: TanyaAICancellable {
    private(set) var isCancelled = false

    func cancel() {
        isCancelled = true
    }
}

final class TanyaAIChatUseCaseFixture: TanyaAIChatUseCaseProtocol {
    let cancellationProbe = TanyaAICancellationProbe()
    private var eventHandler: ((TanyaAIStreamEvent) -> Void)?

    func sendMessage(
        conversationIdentifier: String?,
        text: String,
        onEvent: @escaping (TanyaAIStreamEvent) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable {
        eventHandler = onEvent
        return cancellationProbe
    }

    func appendStatusMessages(count: Int) {
        for index in 0..<count {
            let payload = TanyaAIStatusPayload(
                title: "Status \(index)",
                detail: "Sanitized performance fixture",
                level: .neutral
            )
            eventHandler?(
                .content(
                    messageIdentifier: "performance-\(index)",
                    content: .status(payload)
                )
            )
        }
    }
}

final class TanyaAIAuthorizationFixture: TanyaAIAuthorizationService {
    let cancellationProbe = TanyaAICancellationProbe()

    func authorize(
        request: TanyaAIAuthorizationRequest,
        pin: String,
        completion: @escaping (
            Result<TanyaAIAuthorizationResult, Error>
        ) -> Void
    ) -> TanyaAICancellable {
        cancellationProbe
    }
}
