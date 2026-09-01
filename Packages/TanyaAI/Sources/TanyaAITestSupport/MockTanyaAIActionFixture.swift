import Foundation

/// Builds a sanitized stream that hands your own deeplinks to the host.
///
/// Point the mock transport at it to see the hand-off end to end without a
/// backend:
///
/// ```swift
/// let transport = MockTanyaAIStreamingTransport(
///     scenario: .custom(
///         MockTanyaAIActionFixture.actionCardChunks(
///             buttons: [
///                 .init(
///                     title: "Open transfer",
///                     deeplink: "ocbcid://mobile?type=transfer"
///                 )
///             ]
///         )
///     )
/// )
/// ```
public enum MockTanyaAIActionFixture {
    /// One button on the generated action card.
    public struct Button {
        public let title: String
        public let style: String
        public let deeplink: String
        public let identifier: String

        /// - Parameters:
        ///   - title: button label.
        ///   - style: `primary` or `secondary`.
        ///   - deeplink: the string the host will receive, unchanged.
        ///   - identifier: action identifier, which also becomes the button's
        ///     accessibility identifier as `action.<identifier>`. Derived from
        ///     the title when omitted.
        public init(
            title: String,
            style: String = "primary",
            deeplink: String,
            identifier: String? = nil
        ) {
            self.title = title
            self.style = style
            self.deeplink = deeplink
            self.identifier = identifier ?? Button.slug(from: title)
        }

        private static func slug(from title: String) -> String {
            let slug = title
                .lowercased()
                .replacingOccurrences(of: " ", with: "-")
            return slug.isEmpty ? "action" : slug
        }
    }

    /// A short reply followed by one action card.
    ///
    /// Use it to check that tapping a button reaches the host, that the host
    /// accepts the deeplink, and that the destination opens after the feature
    /// closes.
    public static func actionCardChunks(
        identifier: String = "demo",
        message: String = "Your existing screens can take over from here.",
        title: String? = "Continue in the app",
        detail: String? = nil,
        buttons: [Button]
    ) -> [Data] {
        let messageIdentifier = "action-text-\(identifier)"
        var events = [
            event("response.started", ["messageIdentifier": messageIdentifier]),
            event(
                "text.delta",
                [
                    "messageIdentifier": messageIdentifier,
                    "text": message
                ]
            ),
            actionsEvent(identifier: identifier, title: title, detail: detail, buttons: buttons)
        ]
        events.append(
            event("response.completed", ["messageIdentifier": messageIdentifier])
        )
        return MockTanyaAIResponseFixture.irregularChunks(from: events.joined())
    }

    /// A confirmation whose Confirm button hands off instead of opening the
    /// in-feature PIN sheet.
    ///
    /// Use it to check the second entry point: the same handler must run, and
    /// the PIN sheet must never appear.
    public static func approvalHandoffChunks(
        identifier: String = "demo",
        title: String = "Confirm your transfer",
        summary: [(label: String, value: String)] = [
            ("To", "Sample Beneficiary"),
            ("Amount", "IDR 1,250,000")
        ],
        deeplink: String
    ) -> [Data] {
        let messageIdentifier = "handoff-text-\(identifier)"
        let events = [
            event("response.started", ["messageIdentifier": messageIdentifier]),
            event(
                "text.delta",
                [
                    "messageIdentifier": messageIdentifier,
                    "text": "Confirm to continue in the existing flow."
                ]
            ),
            event(
                "content.approval",
                [
                    "messageIdentifier": "handoff-approval-\(identifier)",
                    "approvalIdentifier": "approval-\(identifier)",
                    "transactionIdentifier": "transaction-\(identifier)",
                    "challengeIdentifier": "challenge-\(identifier)",
                    "kind": "transfer",
                    "title": title,
                    "summary": summary.map {
                        ["label": $0.label, "value": $0.value]
                    },
                    "expiresAt": "2099-01-01T00:00:00Z",
                    "handoff": [
                        "identifier": "handoff-\(identifier)",
                        "deeplink": deeplink
                    ]
                ]
            ),
            event("response.completed", ["messageIdentifier": messageIdentifier])
        ]
        return MockTanyaAIResponseFixture.irregularChunks(from: events.joined())
    }

    static func actionsEvent(
        identifier: String,
        title: String?,
        detail: String?,
        buttons: [Button]
    ) -> String {
        var payload: [String: Any] = [
            "messageIdentifier": "action-card-\(identifier)",
            "actions": buttons.map { button in
                [
                    "title": button.title,
                    "style": button.style,
                    "action": [
                        "identifier": button.identifier,
                        "deeplink": button.deeplink
                    ]
                ]
            }
        ]
        if let title {
            payload["title"] = title
        }
        if let detail {
            payload["detail"] = detail
        }
        return event("content.actions", payload)
    }

    private static func event(
        _ name: String,
        _ payload: [String: Any]
    ) -> String {
        MockTanyaAIResponseFixture.event(name, payload)
    }
}
