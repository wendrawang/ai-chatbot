import Foundation
import TanyaAIContracts

/// Stands in for a vendor session so the repository's mapping and turn
/// bookkeeping can be asserted without any SDK.
enum SessionError: Error {
    case dropped
}

final class SessionSpy: TanyaAIChatSession {
    var onEvent: ((TanyaAIChatSessionEvent) -> Void)?
    private(set) var requestIdentifiers: [String] = []
    private(set) var sentTexts: [String] = []
    private(set) var sentContexts: [TanyaAIContext?] = []
    private(set) var isConnected = false
    var connectionEvents: [TanyaAIChatSessionEvent] = []

    func connect() {
        isConnected = true
        connectionEvents.forEach { onEvent?($0) }
    }

    func send(
        text: String,
        context: TanyaAIContext?,
        requestIdentifier: String
    ) -> String? {
        requestIdentifiers.append(requestIdentifier)
        sentTexts.append(text)
        sentContexts.append(context)
        return "sdk-" + requestIdentifier
    }

    func disconnect() {
        isConnected = false
    }

    func emit(_ event: TanyaAIChatSessionEvent) {
        onEvent?(event)
    }
}
