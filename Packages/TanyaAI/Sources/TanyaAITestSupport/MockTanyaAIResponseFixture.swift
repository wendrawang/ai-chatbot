import Foundation
import TanyaAIContracts

enum MockTanyaAIResponseFixture {
    typealias ContentEvent = (name: String, payload: [String: Any])

    /// Picks a canned answer from what the customer typed.
    static func events(for prompt: String) -> [TanyaAIChatSessionEvent] {
        let prompt = prompt.lowercased()
        let identifier = UUID().uuidString.prefix(8).lowercased()

        if prompt.contains("showcase") {
            return MockTanyaAIShowcaseFixture.events(identifier: String(identifier))
        }
        if prompt.contains("deeplink") {
            return MockTanyaAIDeeplinkFixture.events(identifier: String(identifier))
        }
        if prompt.contains("conversion") || prompt.contains("currency") {
            return MockTanyaAIConfirmationFixture.conversionEvents(String(identifier))
        }
        if prompt.contains("deposit") {
            return MockTanyaAIConfirmationFixture.depositEvents(String(identifier))
        }
        if prompt.contains("saving") {
            return MockTanyaAIConfirmationFixture.savingsEvents(String(identifier))
        }
        if prompt.contains("incoming") {
            return MockTanyaAIInsightFixture.incomingEvents(String(identifier))
        }
        if prompt.contains("bill") {
            return MockTanyaAIInsightFixture.billsEvents(String(identifier))
        }
        if prompt.contains("spending") {
            return MockTanyaAIInsightFixture.spendingEvents(String(identifier))
        }
        if prompt.contains("limit") {
            return MockTanyaAIInsightFixture.informationEvents(String(identifier))
        }
        if prompt.contains("transfer") {
            return MockTanyaAIConfirmationFixture.transferEvents(String(identifier))
        }
        return MockTanyaAIInsightFixture.portfolioEvents(String(identifier))
    }

    static func response(
        identifier: String,
        text: String,
        contents: [ContentEvent],
        suggestions: [[String: String]]
    ) -> [TanyaAIChatSessionEvent] {
        let textIdentifier = "text-\(identifier)"
        var events = [
            event("response_started", ["messageIdentifier": textIdentifier]),
            event(
                "text_delta",
                ["messageIdentifier": textIdentifier, "text": text]
            )
        ]
        events.append(contentsOf: contentEvents(contents, identifier: identifier))
        events.append(event("suggestions", ["suggestions": suggestions]))
        events.append(
            event("response_completed", ["messageIdentifier": textIdentifier])
        )
        return events
    }

    static func contentEvent(
        _ name: String,
        prefix: String,
        identifier: String,
        payload: [String: Any]
    ) -> TanyaAIChatSessionEvent {
        var content = payload
        content["messageIdentifier"] = "\(prefix)-\(identifier)"
        return event(name, content)
    }

    /// Turns one fixture event into the session event that carries it.
    ///
    /// Text framing has dedicated cases - the turn only ends on
    /// `messageCompleted`. Everything else rides `structuredPayload`, which is
    /// exactly how a real bot ships a typed card over a vendor channel.
    static func event(
        _ name: String,
        _ payload: [String: Any]
    ) -> TanyaAIChatSessionEvent {
        do {
            let json = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
            return try .fromWire(name: name, json: json)
        } catch {
            return .failed(error)
        }
    }

    private static func contentEvents(
        _ contents: [ContentEvent],
        identifier: String
    ) -> [TanyaAIChatSessionEvent] {
        contents.enumerated().map { index, content in
            contentEvent(
                content.name,
                prefix: "content-\(index)",
                identifier: identifier,
                payload: content.payload
            )
        }
    }
}
