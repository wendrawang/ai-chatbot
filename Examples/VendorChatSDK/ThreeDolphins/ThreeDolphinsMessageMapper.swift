import Foundation
import TanyaAI

/// An explicit HOST contract, not a documented 3Dolphins notification schema.
/// Use only after adapting the actual SDK payload to this shape.
enum ThreeDolphinsMessageMapper {
    /// userInfo contains event: String and data: JSON object.
    /// Empty event means a complete text message. Streaming uses explicit wire events.
    static func map(_ notification: Notification) throws -> [TanyaAIChatSessionEvent] {
        guard let values = notification.userInfo,
              let name = values["event"] as? String,
              let payload = values["data"] as? [String: Any] else {
            throw ThreeDolphinsAdapterError.invalidPayload
        }
        return try events(name: name, payload: payload)
    }

    static func events(
        name: String,
        payload: [String: Any]
    ) throws -> [TanyaAIChatSessionEvent] {
        if name.isEmpty {
            return try textEvents(payload)
        }
        let json = try JSONSerialization.data(withJSONObject: payload)
        let event = try TanyaAIChatSessionEvent.fromWire(name: name, json: json)
        guard TanyaAIEventName.isContentName(name) else { return [event] }
        let identifier = try messageIdentifier(payload)
        return [event, .messageCompleted(messageIdentifier: identifier)]
    }

    private static func textEvents(_ payload: [String: Any]) throws -> [TanyaAIChatSessionEvent] {
        let identifier = try messageIdentifier(payload)
        guard let text = payload["text"] as? String else {
            throw ThreeDolphinsAdapterError.invalidPayload
        }
        return [
            .messageStarted(messageIdentifier: identifier),
            .messageDelta(messageIdentifier: identifier, text: text),
            .messageCompleted(messageIdentifier: identifier)
        ]
    }

    private static func messageIdentifier(_ payload: [String: Any]) throws -> String {
        guard let identifier = payload["messageIdentifier"] as? String,
              identifier.isEmpty == false else {
            throw ThreeDolphinsAdapterError.invalidPayload
        }
        return identifier
    }
}
