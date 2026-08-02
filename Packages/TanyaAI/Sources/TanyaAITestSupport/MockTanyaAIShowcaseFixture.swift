import Foundation

enum MockTanyaAIShowcaseFixture {
    static func chunks(identifier: String) -> [Data] {
        MockTanyaAIResponseFixture.irregularChunks(
            from: events(identifier: identifier).joined()
        )
    }

    private static func events(identifier: String) -> [String] {
        var events = textEvents(identifier: identifier)
        events.append(informationEvent(identifier: identifier))
        events.append(chartEvent(identifier: identifier))
        events.append(portfolioEvent(identifier: identifier))
        events.append(approvalEvent(identifier: identifier))
        events.append(contentsOf: statusEvents(identifier: identifier))
        events.append(completedEvent(identifier: identifier))
        return events
    }

    private static func textEvents(identifier: String) -> [String] {
        let messageIdentifier = "showcase-text-\(identifier)"
        return [
            event(
                "response.started",
                ["messageIdentifier": messageIdentifier]
            ),
            event(
                "text.delta",
                [
                    "messageIdentifier": messageIdentifier,
                    "text": "Here are all sanitized bubble permutations."
                ]
            )
        ]
    }

    private static func informationEvent(identifier: String) -> String {
        event(
            "content.information",
            [
                "messageIdentifier": "showcase-info-\(identifier)",
                "title": "Information bubble",
                "text": "Generic, allowlisted information content.",
                "items": [
                    ["label": "Daily limit", "value": "USD 5,000"],
                    ["label": "Remaining", "value": "USD 3,750"]
                ]
            ]
        )
    }

    private static func chartEvent(identifier: String) -> String {
        event(
            "content.chart",
            [
                "messageIdentifier": "showcase-chart-\(identifier)",
                "title": "Spending chart",
                "subtitle": "Sanitized sample values",
                "chartType": "bar",
                "series": chartSeries
            ]
        )
    }

    private static func portfolioEvent(identifier: String) -> String {
        event(
            "content.portfolio",
            [
                "messageIdentifier": "showcase-portfolio-\(identifier)",
                "title": "Sample portfolio",
                "totalValue": "USD 12,500",
                "performanceText": "Up 3.2% in this demo",
                "allocations": chartSeries
            ]
        )
    }

    private static func approvalEvent(identifier: String) -> String {
        event(
            "content.approval",
            [
                "messageIdentifier": "showcase-approval-\(identifier)",
                "approvalIdentifier": "showcase-approval-001",
                "transactionIdentifier": "showcase-transaction-001",
                "challengeIdentifier": "showcase-challenge-001",
                "title": "Approve sample transfer",
                "summary": [
                    ["label": "Recipient", "value": "Demo Recipient"],
                    ["label": "Amount", "value": "USD 25.00"]
                ],
                "expiresAt": "2030-01-01T00:00:00Z"
            ]
        )
    }

    private static func statusEvents(identifier: String) -> [String] {
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
                    "messageIdentifier": "showcase-status-\(index)-\(identifier)",
                    "title": state.1,
                    "detail": state.2,
                    "level": state.0
                ]
            )
        }
    }

    private static func completedEvent(identifier: String) -> String {
        event(
            "response.completed",
            ["messageIdentifier": "showcase-text-\(identifier)"]
        )
    }

    private static func event(
        _ name: String,
        _ payload: [String: Any]
    ) -> String {
        MockTanyaAIResponseFixture.event(name, payload)
    }

    private static let chartSeries: [[String: Any]] = [
        ["label": "Groceries", "value": 55, "formattedValue": "55%"],
        ["label": "Transport", "value": 30, "formattedValue": "30%"],
        ["label": "Other", "value": 15, "formattedValue": "15%"]
    ]
}
