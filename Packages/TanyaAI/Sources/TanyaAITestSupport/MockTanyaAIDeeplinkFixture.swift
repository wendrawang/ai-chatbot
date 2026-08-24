import Foundation

/// Sanitized fixture for the sandbox hand-off demo.
///
/// One response carrying both entry points: an action card and a confirmation
/// that hands off instead of opening the in-feature PIN sheet. The third
/// button carries an `https` link on purpose — the host must reject it.
///
/// Host applications should build their own with
/// `MockTanyaAIActionFixture` rather than reuse this one: the deeplinks here
/// are the sandbox's, not yours.
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
            MockTanyaAIActionFixture.actionsEvent(
                identifier: identifier,
                title: "Continue in the app",
                detail: "These open the existing screens.",
                buttons: buttons
            ),
            handoffApprovalEvent(identifier),
            event(
                "response.completed",
                ["messageIdentifier": messageIdentifier]
            )
        ]
    }

    private static var buttons: [MockTanyaAIActionFixture.Button] {
        [
            MockTanyaAIActionFixture.Button(
                title: "Open transfer form",
                deeplink:
                    "tanyaaisandbox://mobile?type=transfer" +
                    "&accountNumber=0000111122",
                identifier: "open-transfer"
            ),
            MockTanyaAIActionFixture.Button(
                title: "Open sample statement",
                style: "secondary",
                deeplink:
                    "tanyaaisandbox://mobile?type=statement&period=2026-07",
                identifier: "open-statement"
            ),
            MockTanyaAIActionFixture.Button(
                title: "Open blocked link",
                style: "secondary",
                deeplink: "https://example.com/promo",
                identifier: "open-blocked"
            )
        ]
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
