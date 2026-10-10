import Foundation
import TanyaAIDomain

final class TanyaAIRepositoryStub: TanyaAIRepository {
    var onEvent: ((TanyaAIStreamEvent) -> Void)?
    var isAutomaticConnection = true
    var isAutomaticAcknowledgement = true
    private(set) var receivedTexts: [String] = []
    private(set) var requestIdentifiers: [String] = []
    private(set) var disconnectCount = 0
    private var lastReplyIdentifier = "reply"
    var receivedText: String? { receivedTexts.last }

    func connect() {
        if isAutomaticConnection {
            onEvent?(.history([]))
            onEvent?(.connectionChanged(.ready))
        }
    }

    @discardableResult
    func sendMessage(text: String, requestIdentifier: String) -> String? {
        receivedTexts.append(text)
        requestIdentifiers.append(requestIdentifier)
        let remoteIdentifier = "sdk-" + requestIdentifier
        if isAutomaticAcknowledgement {
            onEvent?(.sendSucceeded(requestIdentifier: requestIdentifier, messageIdentifier: remoteIdentifier))
        }
        return remoteIdentifier
    }

    func disconnect() { disconnectCount += 1 }

    func send(_ event: TanyaAIStreamEvent) {
        if case .textDelta(let identifier, _) = event { lastReplyIdentifier = identifier }
        onEvent?(event)
    }

    func sendUnsolicited(_ event: TanyaAIStreamEvent) { send(event) }
    func complete(_ result: Result<Void, Error>) {
        if case .failure = result {
            if let identifier = requestIdentifiers.last { send(.sendFailed(requestIdentifier: identifier)) }
        } else {
            send(.responseCompleted(messageIdentifier: lastReplyIdentifier))
        }
    }
}
