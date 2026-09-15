import Foundation
import TanyaAIContracts

enum MockTanyaAIShowcaseFixture {
    static func events(identifier: String) -> [TanyaAIChatSessionEvent] {
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
                        + "scenarios.\n\n[bold]1. Confirmations[/bold]: "
                        + "approval cards that lead to authorization.\n"
                        + "[bold]2. Insights[/bold]: portfolio, spending, "
                        + "and lists.\n[bold]3. Status[/bold]: every level, "
                        + "plus the unsupported fallback.\n\nStatus: "
                        + "[color]sandbox data only|25C36B[/color], "
                        + "[strike]production endpoints[/strike]."
                ]
            )
        ]
        events.append(imageEvent(identifier))
        events.append(
            contentsOf: MockTanyaAIConfirmationFixture.showcaseEvents(identifier)
        )
        events.append(
            contentsOf: MockTanyaAIInsightFixture.showcaseEvents(identifier)
        )
        events.append(choicesEvent(identifier))
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

    /// The one fixture that reaches the network.
    ///
    /// An image bubble cannot be demonstrated without an image, and the
    /// package ships no assets of its own. A simulator with no route still
    /// lays the row out at its reserved height and keeps the caption, which
    /// is what the screenshot test anchors on.
    private static func imageEvent(
        _ identifier: String
    ) -> TanyaAIChatSessionEvent {
        event(
            "content.image",
            [
                "messageIdentifier": "image-\(identifier)",
                "imageURL": "https://picsum.photos/seed/tanyaai/920/575",
                "caption": "Jalani misinya, dapatkan Bonus Bunga Tabungan "
                    + "hingga 5,25% p.a.",
                "aspectRatio": 1.6,
                "accessibilityText": "Sample promo artwork"
            ]
        )
    }

    /// A question answered by picking and confirming, so the showcase shows
    /// the one bubble that holds state of its own.
    private static func choicesEvent(
        _ identifier: String
    ) -> TanyaAIChatSessionEvent {
        event(
            "content.choices",
            [
                "messageIdentifier": "choices-\(identifier)",
                "title": "Kategori apa yang diinginkan",
                "choices": [
                    choice("dining", "Dining", "Promo dining"),
                    choice("travel", "Hotel & Travel", "Promo hotel"),
                    choice("grocery", "Grocery", "Promo grocery"),
                    choice("fuel", "Bahan bakar", "Promo bahan bakar")
                ],
                "submitTitle": "Kirim"
            ]
        )
    }

    private static func choice(
        _ identifier: String,
        _ title: String,
        _ prompt: String
    ) -> [String: String] {
        ["identifier": identifier, "title": title, "prompt": prompt]
    }

    private static func statusEvents(
        _ identifier: String
    ) -> [TanyaAIChatSessionEvent] {
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

    private static func unsupportedEvent(
        _ identifier: String
    ) -> TanyaAIChatSessionEvent {
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
    ) -> TanyaAIChatSessionEvent {
        MockTanyaAIResponseFixture.event(name, payload)
    }
}
