import Foundation

enum MockTanyaAIStressFixture {
    static let messageCount = 5_000

    static func chunks(identifier: String) -> [Data] {
        var events = [startedEvent(identifier)]
        events.append(contentsOf: statusEvents(identifier))
        events.append(suggestionEvent)
        events.append(completedEvent(identifier))

        return stride(from: 0, to: events.count, by: 100).map { start in
            let end = min(start + 100, events.count)
            return Data(events[start..<end].joined().utf8)
        }
    }

    private static func statusEvents(_ identifier: String) -> [String] {
        (1...messageCount).map { index in
            MockTanyaAIResponseFixture.event(
                "content.status",
                [
                    "messageIdentifier": "stress-\(index)-\(identifier)",
                    "title": "Stress message \(index)",
                    "detail": "Sanitized large-conversation fixture",
                    "level": "neutral"
                ]
            )
        }
    }

    private static func startedEvent(_ identifier: String) -> String {
        MockTanyaAIResponseFixture.event(
            "response.started",
            ["messageIdentifier": "stress-start-\(identifier)"]
        )
    }

    private static func completedEvent(_ identifier: String) -> String {
        MockTanyaAIResponseFixture.event(
            "response.completed",
            ["messageIdentifier": "stress-start-\(identifier)"]
        )
    }

    private static var suggestionEvent: String {
        MockTanyaAIResponseFixture.event(
            "response.suggestions",
            [
                "suggestions": [[
                    "identifier": "stress-next",
                    "title": "Next sample",
                    "prompt": "Show portfolio"
                ]]
            ]
        )
    }
}
