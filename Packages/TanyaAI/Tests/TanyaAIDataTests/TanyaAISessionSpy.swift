import Foundation
import TanyaAIContracts

/// Stands in for a vendor session so the repository's mapping and turn
/// bookkeeping can be asserted without any SDK.
enum SessionError: Error {
    case dropped
}

final class SessionSpy: TanyaAIChatSession {
    var onEvent: ((TanyaAIChatSessionEvent) -> Void)?
    private(set) var sentTexts: [String] = []
    private(set) var sentContexts: [TanyaAIContext?] = []
    private(set) var isConnected = false

    func connect() {
        isConnected = true
    }

    func send(
        text: String,
        context: TanyaAIContext?,
        requestIdentifier: String
    ) {
        sentTexts.append(text)
        sentContexts.append(context)
    }

    func disconnect() {
        isConnected = false
    }

    func emit(_ event: TanyaAIChatSessionEvent) {
        onEvent?(event)
    }
}
