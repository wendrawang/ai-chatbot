import Foundation

/// Sanitized fixture for the host hand-off demo.
///
/// Streams one action card and one approval that hands off to the host instead
/// of opening the in-feature PIN sheet. The third button carries an `https`
/// link on purpose: the host must reject it.
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
                            "deeplink":
                                "tanyaaisandbox://mobile?type=transfer" +
                                "&accountNumber=0000111122"
                        ]
                    ],
                    [
                        "title": "Open sample statement",
                        "style": "secondary",
                        "action": [
                            "identifier": "open-statement",
                            "deeplink":
                                "tanyaaisandbox://mobile?type=statement" +
                                "&period=2026-07"
                        ]
                    ],
                    [
                        "title": "Open blocked link",
                        "style": "secondary",
                        "action": [
                            "identifier": "open-blocked",
                            "deeplink": "https://example.com/promo"
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
                    "deeplink":
                        "tanyaaisandbox://mobile?type=transfer&amount=1250000"
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
