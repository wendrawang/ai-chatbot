import Foundation

public extension TanyaAIChatSessionEvent {
    /// Pass only the payload object as JSON, not the surrounding vendor envelope.
    static func fromWire(name: String, json: Data) throws -> Self {
        let event = TanyaAIEventName(wireName: name)
        let decoder = JSONDecoder()
        switch event {
        case .responseStarted:
            let payload = try decoder.decode(WireIdentifier.self, from: json)
            return .messageStarted(messageIdentifier: payload.messageIdentifier)
        case .textDelta:
            let payload = try decoder.decode(WireText.self, from: json)
            return .messageDelta(messageIdentifier: payload.messageIdentifier, text: payload.text)
        case .responseCompleted:
            let payload = try decoder.decode(WireIdentifier.self, from: json)
            return .messageCompleted(messageIdentifier: payload.messageIdentifier)
        default:
            return .structuredPayload(name: event?.rawValue ?? name, json: json)
        }
    }
}

private struct WireIdentifier: Decodable {
    let messageIdentifier: String
}

private struct WireText: Decodable {
    let messageIdentifier: String
    let text: String
}
