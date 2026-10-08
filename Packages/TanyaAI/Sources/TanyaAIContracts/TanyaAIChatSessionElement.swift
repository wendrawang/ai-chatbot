import Foundation

/// SDK-neutral message parts. The host unwraps its vendor envelope first.
public enum TanyaAIChatSessionElement {
    case text(String)
    /// UTF-8 JSON from the custom element's data, with its original `type`.
    case custom(Data)
}

public extension TanyaAIChatSessionMessage {
    /// Preserves one vendor message as one row, including composite answers.
    init(identifier: String, author: Author, elements: [TanyaAIChatSessionElement]) throws {
        let parts = try elements.map { element -> [String: Any] in
            switch element {
            case .text(let text): return ["type": "text", "text": text]
            case .custom(let data):
                guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    throw CocoaError(.coderReadCorrupt)
                }
                return object
            }
        }
        let json = try JSONSerialization.data(withJSONObject: [
            "messageIdentifier": identifier, "elements": parts
        ])
        self.init(identifier: identifier, author: author, text: "", structuredName: "components", structuredJSON: json)
    }

    /// Live and history use exactly the same payload, including the stable message ID.
    var contentEvents: [TanyaAIChatSessionEvent] {
        if let name = structuredName, let json = structuredJSON {
            return [.structuredPayload(name: name, json: json), .messageCompleted(messageIdentifier: identifier)]
        }
        return [
            .messageStarted(messageIdentifier: identifier),
            .messageDelta(messageIdentifier: identifier, text: text),
            .messageCompleted(messageIdentifier: identifier)
        ]
    }
}
