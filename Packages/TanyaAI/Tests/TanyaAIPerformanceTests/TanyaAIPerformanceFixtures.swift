import DesignKit
import Foundation
import TanyaAIContracts
import TanyaAIDomain

final class TanyaAICancellationProbe: TanyaAICancellable {
    private(set) var isCancelled = false

    func cancel() {
        isCancelled = true
    }
}

final class TanyaAIRepositoryFixture: TanyaAIRepository {
    var onEvent: ((TanyaAIStreamEvent) -> Void)?
    private(set) var isDisconnected = false
    func connect() {
        onEvent?(.history([]))
        onEvent?(.connectionChanged(.ready))
    }
    func disconnect() { isDisconnected = true }
    func sendMessage(text: String, requestIdentifier: String) -> String? {
        onEvent?(.sendSucceeded(requestIdentifier: requestIdentifier, messageIdentifier: requestIdentifier))
        return requestIdentifier
    }
    func appendStatusMessages(count: Int) {
        for index in 0..<count {
            let payload = StatusPayload(
                title: "Status \(index)", detail: "Sanitized performance fixture", level: .neutral
            )
            onEvent?(.content(messageIdentifier: "performance-\(index)", content: .status(payload)))
        }
        onEvent?(.typing(true))
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
