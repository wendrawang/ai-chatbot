import Foundation

enum MockTanyaAIConfirmationFixture {
    static func conversionChunks(_ identifier: String) -> [Data] {
        response(
            identifier,
            text: "Review the indicative conversion before confirming.",
            content: conversionContent
        )
    }

    static func depositChunks(_ identifier: String) -> [Data] {
        response(
            identifier,
            text: "Review the time deposit details before confirming.",
            content: depositContent
        )
    }

    static func transferChunks(_ identifier: String) -> [Data] {
        response(
            identifier,
            text: "Review the demo transfer before confirming.",
            content: transferContent
        )
    }

    static func savingsChunks(_ identifier: String) -> [Data] {
        response(
            identifier,
            text: "Review the savings plan before confirming.",
            content: savingsContent
        )
    }

    static func showcaseEvents(_ identifier: String) -> [String] {
        let contents = [
            conversionContent,
            conversionReceipt,
            depositContent,
            transferContent,
            savingsContent
        ]
        return contents.enumerated().map { index, content in
            MockTanyaAIResponseFixture.contentEvent(
                content.name,
                prefix: "confirmation-\(index)",
                identifier: identifier,
                payload: content.payload
            )
        }
    }

    private static func response(
        _ identifier: String,
        text: String,
        content: MockTanyaAIResponseFixture.ContentEvent
    ) -> [Data] {
        MockTanyaAIResponseFixture.responseChunks(
            identifier: identifier,
            text: text,
            contents: [content],
            suggestions: suggestions
        )
    }

    private static let conversionContent = approval(
        kind: "currencyConversion",
        title: "Confirm currency conversion",
        summary: [
            item("You convert", "USD 1,000.00"),
            item("Rate (bank sell)", "1 USD = IDR 16,250"),
            item("You receive", "IDR 16,250,000"),
            item("From → To", "USD ••2201 → IDR ••8821")
        ],
        notice: "The indicative rate may refresh during authorization."
    )

    private static let depositContent = approval(
        kind: "timeDeposit",
        title: "Confirm time deposit",
        summary: [
            item("Amount", "IDR 100,000,000"),
            item("Tenor", "1 month"),
            item("Rate p.a. (indicative)", "3.75%"),
            item("Interest at maturity", "IDR 312,500"),
            item("Source", "Premier ••8821"),
            item("At maturity", "Renew principal"),
            item("Maturity date", "23 Aug 2026")
        ],
        notice: "The rate is confirmed at placement."
    )

    private static let transferContent = approval(
        kind: "transfer",
        title: "Confirm your transfer",
        summary: [
            item("From", "Premier Account · ••8821"),
            item("To", "My Savings · ••4590"),
            item("Amount", "IDR 5,000,000"),
            item("Fee", "IDR 0"),
            item("When", "Now")
        ],
        notice: "Check the details before authorization."
    )

    private static let savingsContent = approval(
        kind: "savingsPlan",
        title: "Confirm savings plan",
        summary: [
            item("Amount", "IDR 2,500,000"),
            item("Frequency", "Monthly · on the 25th"),
            item("From → To", "Premier ••8821 → Goal ••4590"),
            item("First debit", "25 Aug 2026"),
            item("Ends", "Until you cancel")
        ],
        notice: "You can pause or stop this demo plan anytime."
    )

    private static let conversionReceipt = (
        name: "content.receipt",
        payload: [
            "title": "Conversion complete",
            "detail": "USD 1,000 converted to IDR 16,250,000",
            "summary": [
                item("New IDR balance", "IDR 41,300,000"),
                item("Reference", "FX-77120934")
            ],
            "footnote": "Secured with your demo PIN."
        ] as [String: Any]
    )

    private static let suggestions = [
        suggestion("spending", "Spending", "Show my spending insight"),
        suggestion("portfolio", "Portfolio", "Show my sample portfolio"),
        suggestion("bills", "Paid bills", "Show paid bills")
    ]

    private static func approval(
        kind: String,
        title: String,
        summary: [[String: String]],
        notice: String
    ) -> MockTanyaAIResponseFixture.ContentEvent {
        let identifier = kind.replacingOccurrences(of: " ", with: "-")
        return (
            name: "content.approval",
            payload: [
                "approvalIdentifier": "demo-\(identifier)-approval",
                "transactionIdentifier": "demo-\(identifier)-transaction",
                "challengeIdentifier": "demo-\(identifier)-challenge",
                "kind": kind,
                "title": title,
                "summary": summary,
                "notice": notice,
                "expiresAt": "2030-01-01T00:00:00Z"
            ]
        )
    }

    private static func item(
        _ label: String,
        _ value: String
    ) -> [String: String] {
        ["label": label, "value": value]
    }

    private static func suggestion(
        _ identifier: String,
        _ title: String,
        _ prompt: String
    ) -> [String: String] {
        ["identifier": identifier, "title": title, "prompt": prompt]
    }
}
