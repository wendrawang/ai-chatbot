import Foundation

enum MockTanyaAIShowcaseFixture {
    static func chunks(identifier: String) -> [Data] {
        MockTanyaAIResponseFixture.irregularChunks(
            from: events(identifier: identifier).joined()
        )
    }

    private static func events(identifier: String) -> [String] {
        let messageIdentifier = "showcase-text-\(identifier)"
        var events = [
            event(
                "response.started",
                ["messageIdentifier": messageIdentifier]
            ),
            event(
                "text.delta",
                [
                    "messageIdentifier": messageIdentifier,
                    "text": "Here are the sanitized financial bubble "
                        + "scenarios.\n\n**1. Confirmations**: approval "
                        + "cards that lead to authorization.\n**2. "
                        + "Insights**: portfolio, spending, and lists.\n"
                        + "**3. Status**: every level, plus the unsupported "
                        + "fallback."
                ]
            )
        ]
        events.append(
            contentsOf: MockTanyaAIConfirmationFixture.showcaseEvents(identifier)
        )
        events.append(
            contentsOf: MockTanyaAIInsightFixture.showcaseEvents(identifier)
        )
        events.append(contentsOf: statusEvents(identifier))
        events.append(unsupportedEvent(identifier))
        events.append(event("response.suggestions", suggestionsPayload))
        events.append(
            event(
                "response.completed",
                ["messageIdentifier": messageIdentifier]
            )
        )
        return events
    }

    private static func statusEvents(_ identifier: String) -> [String] {
        let states = [
            ("neutral", "Information", "A neutral system update."),
            ("success", "Completed", "The sample request completed."),
            ("warning", "Attention", "Review this demo warning."),
            ("error", "Unavailable", "A recoverable demo error occurred.")
        ]
        return states.enumerated().map { index, state in
            event(
                "content.status",
                [
                    "messageIdentifier": "status-\(index)-\(identifier)",
                    "title": state.1,
                    "detail": state.2,
                    "level": state.0
                ]
            )
        }
    }

    private static let suggestionsPayload: [String: Any] = [
        "suggestions": [
            suggestion("conversion", "Currency", "Create currency conversion"),
            suggestion("deposit", "Time deposit", "Create time deposit"),
            suggestion("incoming", "Incoming", "Show incoming funds")
        ]
    ]

    private static func unsupportedEvent(_ identifier: String) -> String {
        event(
            "content.future-card",
            [
                "messageIdentifier": "unsupported-\(identifier)",
                "fallbackText": "Update the app to view this sample card."
            ]
        )
    }

    private static func suggestion(
        _ identifier: String,
        _ title: String,
        _ prompt: String
    ) -> [String: String] {
        ["identifier": identifier, "title": title, "prompt": prompt]
    }

    private static func event(
        _ name: String,
        _ payload: [String: Any]
    ) -> String {
        MockTanyaAIResponseFixture.event(name, payload)
    }
}
