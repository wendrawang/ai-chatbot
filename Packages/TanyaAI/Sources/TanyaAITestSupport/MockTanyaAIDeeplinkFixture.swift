import Foundation

/// Sanitized fixture for the host hand-off demo.
///
/// Streams one action card and one approval that hands off to the host instead
/// of opening the in-feature PIN sheet.
enum MockTanyaAIDeeplinkFixture {
    static func chunks(identifier: String) -> [Data] {
        MockTanyaAIResponseFixture.irregularChunks(
            from: events(identifier: identifier).joined()
        )
    }

    private static func events(identifier: String) -> [String] {
        let messageIdentifier = "deeplink-text-\(identifier)"
        return [
            event(
                "response.started",
                ["messageIdentifier": messageIdentifier]
            ),
            event(
                "text.delta",
                [
                    "messageIdentifier": messageIdentifier,
                    "text": "Your existing screens can take over from here."
                ]
            ),
            actionsEvent(identifier),
            handoffApprovalEvent(identifier),
            event(
                "response.completed",
                ["messageIdentifier": messageIdentifier]
            )
        ]
    }

    private static func actionsEvent(_ identifier: String) -> String {
        event(
            "content.actions",
            [
                "messageIdentifier": "deeplink-actions-\(identifier)",
                "title": "Continue in the app",
                "detail": "These open the existing screens.",
                "actions": [
                    [
                        "title": "Open transfer form",
                        "style": "primary",
                        "action": [
                            "identifier": "open-transfer",
                            "route": "transfer.form",
                            "parameters": ["accountNumber": "0000111122"]
                        ]
                    ],
                    [
                        "title": "Open sample statement",
                        "style": "secondary",
                        "action": [
                            "identifier": "open-statement",
                            "route": "statement.detail",
                            "parameters": ["period": "2026-07"]
                        ]
                    ],
                    [
                        "title": "Open blocked route",
                        "style": "secondary",
                        "action": [
                            "identifier": "open-blocked",
                            "route": "settings.secret"
                        ]
                    ]
                ]
            ]
        )
    }

    private static func handoffApprovalEvent(_ identifier: String) -> String {
        event(
            "content.approval",
            [
                "messageIdentifier": "deeplink-approval-\(identifier)",
                "approvalIdentifier": "approval-handoff-\(identifier)",
                "transactionIdentifier": "transaction-handoff",
                "challengeIdentifier": "challenge-handoff",
                "kind": "transfer",
                "title": "Confirm your transfer",
                "summary": [
                    ["label": "To", "value": "Sample Beneficiary"],
                    ["label": "Amount", "value": "IDR 1,250,000"]
                ],
                "notice": "Authorization happens in the existing flow.",
                "expiresAt": "2099-01-01T00:00:00Z",
                "handoff": [
                    "identifier": "handoff-transfer",
                    "route": "transfer.form",
                    "parameters": ["amount": "1250000"]
                ]
            ]
        )
    }

    private static func event(
        _ name: String,
        _ payload: [String: Any]
    ) -> String {
        MockTanyaAIResponseFixture.event(name, payload)
    }
}
