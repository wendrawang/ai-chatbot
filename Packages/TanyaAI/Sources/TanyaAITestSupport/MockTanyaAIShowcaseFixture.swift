import Foundation
import TanyaAIContracts

enum MockTanyaAIShowcaseFixture {
    static func events(identifier: String) -> [TanyaAIChatSessionEvent] {
        let messageIdentifier = "showcase-text-\(identifier)"
        var events = [
            event(
                "response_started",
                ["messageIdentifier": messageIdentifier]
            ),
            event(
                "text_delta",
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
        events.append(contentsOf: bubbleEvents(identifier))
        events.append(event("suggestions", suggestionsPayload))
        events.append(
            event(
                "response_completed",
                ["messageIdentifier": messageIdentifier]
            )
        )
        return events
    }

    /// Every bubble, in the order the conversation shows them.
    ///
    /// The screenshot test walks this order by scrolling forward only, so
    /// moving one of these moves where its scenario has to be listed.
    private static func bubbleEvents(
        _ identifier: String
    ) -> [TanyaAIChatSessionEvent] {
        var events = [imageEvent(identifier)]
        events.append(
            contentsOf: MockTanyaAIConfirmationFixture.showcaseEvents(identifier)
        )
        events.append(
            contentsOf: MockTanyaAIInsightFixture.showcaseEvents(identifier)
        )
        events.append(choicesEvent(identifier))
        events.append(liveAgentEvent(identifier))
        events.append(htmlEvent(identifier))
        events.append(contentsOf: statusEvents(identifier))
        events.append(unsupportedEvent(identifier))
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
            "image",
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

    /// Static HTML, which is what the bubble is for: a small table that
    /// would be fussy to describe as a card.
    private static func htmlEvent(
        _ identifier: String
    ) -> TanyaAIChatSessionEvent {
        event(
            "html",
            [
                "messageIdentifier": "html-\(identifier)",
                "html": """
                <table>
                  <tr><th>Tenor</th><th>Imbalan</th></tr>
                  <tr><td>2 tahun</td><td>6,40% p.a.</td></tr>
                  <tr><td>5 tahun</td><td>6,90% p.a.</td></tr>
                </table>
                """,
                "height": 120,
                "accessibilityText": "Tabel tenor dan imbalan"
            ]
        )
    }

    private static func liveAgentEvent(
        _ identifier: String
    ) -> TanyaAIChatSessionEvent {
        event(
            "live_agent",
            [
                "messageIdentifier": "agent-\(identifier)",
                "title": "Anda akan diarahkan ke agen kami",
                "detail": "Agen A siap membantu Anda.",
                "continueTitle": "Lanjut",
                "cancelTitle": "Batal",
                "action": [
                    "identifier": "open-live-agent",
                    "deeplink": "tanyaai-sandbox://deeplink?type=live-agent"
                ]
            ]
        )
    }

    /// A question answered by picking and confirming, so the showcase shows
    /// the one bubble that holds state of its own.
    private static func choicesEvent(
        _ identifier: String
    ) -> TanyaAIChatSessionEvent {
        event(
            "choices",
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
                "status",
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
            "future_card",
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
