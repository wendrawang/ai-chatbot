import Foundation

enum MockTanyaAIInsightFixture {
    static func portfolioChunks(_ identifier: String) -> [Data] {
        response(
            identifier,
            text: "Here is your sanitized portfolio overview.",
            contents: [portfolioContent, holdingsContent]
        )
    }

    static func spendingChunks(_ identifier: String) -> [Data] {
        response(
            identifier,
            text: "Here is your month-to-date spending overview.",
            contents: [spendingContent, billsContent]
        )
    }

    static func informationChunks(_ identifier: String) -> [Data] {
        response(
            identifier,
            text: "Here is a sample limit overview.",
            contents: [informationContent]
        )
    }

    static func incomingChunks(_ identifier: String) -> [Data] {
        response(
            identifier,
            text: "These are your incoming demo transactions.",
            contents: [incomingContent]
        )
    }

    static func billsChunks(_ identifier: String) -> [Data] {
        response(
            identifier,
            text: "These are your paid demo bills.",
            contents: [billsContent]
        )
    }

    static func showcaseEvents(_ identifier: String) -> [String] {
        [
            makeEvent(informationContent, prefix: "information", identifier),
            makeEvent(portfolioContent, prefix: "portfolio", identifier),
            makeEvent(holdingsContent, prefix: "holdings", identifier),
            makeEvent(spendingContent, prefix: "spending", identifier),
            makeEvent(billsContent, prefix: "bills", identifier),
            makeEvent(incomingContent, prefix: "incoming", identifier)
        ]
    }

    private static func response(
        _ identifier: String,
        text: String,
        contents: [MockTanyaAIResponseFixture.ContentEvent]
    ) -> [Data] {
        MockTanyaAIResponseFixture.responseChunks(
            identifier: identifier,
            text: text,
            contents: contents,
            suggestions: suggestions
        )
    }

    private static func makeEvent(
        _ content: MockTanyaAIResponseFixture.ContentEvent,
        prefix: String,
        _ identifier: String
    ) -> String {
        MockTanyaAIResponseFixture.contentEvent(
            content.name,
            prefix: prefix,
            identifier: identifier,
            payload: content.payload
        )
    }

    private static let portfolioContent = (
        name: "content.portfolio",
        payload: [
            "title": "Portfolio summary",
            "totalValue": "IDR 2,451,000,000",
            "performanceText": "▲ 3.2% this year (indicative)",
            "allocations": portfolioSeries,
            "footnote": "Figures are indicative and for information only."
        ] as [String: Any]
    )

    private static let holdingsContent = (
        name: "content.financial-list",
        payload: [
            "title": "Your mutual funds",
            "style": "holdings",
            "rows": [
                row("Balanced Growth", value: "IDR 0.62 B", detail: "▲ 4.1% YTD"),
                row("Fixed Income Plus", value: "IDR 0.40 B", detail: "▲ 2.6% YTD"),
                row("Global Equity Feeder", value: "IDR 0.18 B", detail: "▲ 6.8% YTD")
            ],
            "footnote": "Past performance does not guarantee future results."
        ] as [String: Any]
    )

    private static let spendingContent = (
        name: "content.chart",
        payload: [
            "title": "Spending · month to date",
            "subtitle": "46 transactions · 12% lower than last month",
            "totalValue": "IDR 24,790,000",
            "chartType": "bar",
            "series": spendingSeries,
            "footnote": "Information only, to help you see your money clearly."
        ] as [String: Any]
    )

    private static let billsContent = (
        name: "content.financial-list",
        payload: [
            "title": "Bills paid · July",
            "style": "paidBills",
            "rows": [
                row("15 Jul · Electricity", value: "IDR 1,240,000"),
                row("15 Jul · Water", value: "IDR 320,000"),
                row("10 Jul · Internet", value: "IDR 549,000"),
                row("08 Jul · Health", value: "IDR 450,000"),
                row("03 Jul · Credit card", value: "IDR 8,700,000")
            ],
            "totalLabel": "Total paid",
            "totalValue": "IDR 11,259,000",
            "totalCaption": "5 bills",
            "footnote": "You still have 2 demo bills due this month."
        ] as [String: Any]
    )

    private static let incomingContent = (
        name: "content.financial-list",
        payload: [
            "title": "Incoming · last 30 days",
            "style": "incoming",
            "rows": [
                positiveRow("18 Jul · Salary", value: "+IDR 62,000,000"),
                positiveRow("12 Jul · Transfer", value: "+IDR 3,500,000"),
                positiveRow("05 Jul · Refund", value: "+IDR 850,000"),
                positiveRow("02 Jul · Transfer", value: "+IDR 1,200,000")
            ],
            "totalLabel": "Total incoming",
            "totalValue": "IDR 67,550,000",
            "totalCaption": "4 transfers",
            "footnote": "Information only. Ask me to filter this demo list."
        ] as [String: Any]
    )

    private static let informationContent = (
        name: "content.information",
        payload: [
            "title": "Sample transfer limit",
            "text": "These values are local demo data only.",
            "items": [
                ["label": "Daily limit", "value": "IDR 50,000,000"],
                ["label": "Remaining", "value": "IDR 37,500,000"]
            ]
        ] as [String: Any]
    )

    private static let portfolioSeries: [[String: Any]] = [
        series("Mutual funds", 49, "IDR 1.20 B"),
        series("Bonds", 33, "IDR 0.80 B"),
        series("Time deposit", 18, "IDR 0.45 B")
    ]

    private static let spendingSeries: [[String: Any]] = [
        series("Bills & utilities", 45, "IDR 11.26 M"),
        series("Shopping & retail", 25, "IDR 6.10 M"),
        series("Food & dining", 14, "IDR 3.40 M"),
        series("Transport", 8, "IDR 2.10 M"),
        series("Others", 8, "IDR 1.94 M")
    ]

    private static let suggestions = [
        suggestion("incoming", "Incoming funds", "Show incoming funds"),
        suggestion("conversion", "Currency conversion", "Create currency conversion"),
        suggestion("deposit", "Time deposit", "Create time deposit")
    ]

    private static func row(
        _ title: String,
        value: String,
        detail: String? = nil
    ) -> [String: Any] {
        var row: [String: Any] = ["title": title, "value": value]
        row["detail"] = detail
        return row
    }

    private static func positiveRow(
        _ title: String,
        value: String
    ) -> [String: Any] {
        ["title": title, "value": value, "tone": "positive"]
    }

    private static func series(
        _ label: String,
        _ value: Double,
        _ formattedValue: String
    ) -> [String: Any] {
        ["label": label, "value": value, "formattedValue": formattedValue]
    }

    private static func suggestion(
        _ identifier: String,
        _ title: String,
        _ prompt: String
    ) -> [String: String] {
        ["identifier": identifier, "title": title, "prompt": prompt]
    }
}
