import Foundation
import TanyaAI
import imi_dolphin_livechat_ios

/// Maps complete native text messages. Streaming and history batching need SDK lifecycle signals.
enum ThreeDolphinsMessageMapper {
    /// SocketManager posts the decrypted DolphinMessage in notification.object.
    /// Customer echoes and metadata-only notifications do not create assistant bubbles.
    static func map(_ notification: Notification) throws -> [TanyaAIChatSessionEvent] {
        guard let message = notification.object as? DolphinMessage else {
            throw ThreeDolphinsAdapterError.invalidPayload
        }
        guard message.isUser != true,
              let text = message.message,
              text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return []
        }
        let identifier = message.transactionId.flatMap { value in
            value.isEmpty ? nil : value
        } ?? UUID().uuidString
        return [
            .messageStarted(messageIdentifier: identifier),
            .messageDelta(messageIdentifier: identifier, text: text),
            .messageCompleted(messageIdentifier: identifier)
        ]
    }

    /// Explicit TanyaAI envelopes remain available for fixtures or a host bridge.
    /// Native message.event/customVariables are not assumed to contain this schema.
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
