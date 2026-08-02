import Foundation
import TanyaAIContracts

enum MockTanyaAIResponseFixture {
    static func chunks(for request: TanyaAIStreamRequest) -> [Data] {
        let prompt = message(from: request).lowercased()
        let responseIdentifier = request.requestIdentifier.lowercased()

        if prompt.contains("showcase") {
            return MockTanyaAIShowcaseFixture.chunks(
                identifier: responseIdentifier
            )
        }
        if prompt.contains("spending") {
            return spendingChunks(identifier: responseIdentifier)
        }
        if prompt.contains("limit") {
            return informationChunks(identifier: responseIdentifier)
        }
        if prompt.contains("transfer") {
            return approvalChunks(identifier: responseIdentifier)
        }
        return portfolioChunks(identifier: responseIdentifier)
    }

    private static func portfolioChunks(identifier: String) -> [Data] {
        responseChunks(
            identifier: identifier,
            text: "Here is your sanitized sample portfolio.",
            contentEvent: "content.portfolio",
            content: [
                "title": "Sample portfolio",
                "totalValue": "USD 12,500",
                "performanceText": "Up 3.2% in this demo",
                "allocations": chartSeries
            ]
        )
    }

    private static func spendingChunks(identifier: String) -> [Data] {
        responseChunks(
            identifier: identifier,
            text: "Your largest demo spending category is groceries.",
            contentEvent: "content.chart",
            content: [
                "title": "Sample monthly spending",
                "subtitle": "Sanitized fixture data",
                "chartType": "bar",
                "series": spendingSeries
            ]
        )
    }

    private static func informationChunks(identifier: String) -> [Data] {
        responseChunks(
            identifier: identifier,
            text: "Here is a sample limit overview.",
            contentEvent: "content.information",
            content: [
                "title": "Sample transfer limit",
                "text": "These values are local demo data only.",
                "items": [
                    ["label": "Daily limit", "value": "USD 5,000"],
                    ["label": "Remaining", "value": "USD 3,750"]
                ]
            ]
        )
    }

    private static func approvalChunks(identifier: String) -> [Data] {
        responseChunks(
            identifier: identifier,
            text: "Review this sample transfer before approval.",
            contentEvent: "content.approval",
            content: [
                "approvalIdentifier": "demo-approval-001",
                "transactionIdentifier": "demo-transaction-001",
                "challengeIdentifier": "demo-challenge-001",
                "title": "Approve sample transfer",
                "summary": approvalSummary,
                "expiresAt": "2030-01-01T00:00:00Z"
            ]
        )
    }

    private static func responseChunks(
        identifier: String,
        text: String,
        contentEvent: String,
        content: [String: Any]
    ) -> [Data] {
        let textIdentifier = "text-\(identifier)"
        let contentIdentifier = "content-\(identifier)"
        var contentPayload = content
        contentPayload["messageIdentifier"] = contentIdentifier

        let events = [
            event(
                "response.started",
                ["messageIdentifier": textIdentifier]
            ),
            event(
                "text.delta",
                ["messageIdentifier": textIdentifier, "text": text]
            ),
            event(contentEvent, contentPayload),
            event(
                "response.completed",
                ["messageIdentifier": textIdentifier]
            )
        ].joined()
        return irregularChunks(from: events)
    }

    static func event(
        _ name: String,
        _ payload: [String: Any]
    ) -> String {
        let data = try? JSONSerialization.data(
            withJSONObject: payload,
            options: [.sortedKeys]
        )
        let json = data.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        return "event: \(name)\ndata: \(json)\n\n"
    }

    static func irregularChunks(from source: String) -> [Data] {
        let data = Data(source.utf8)
        let lengths = [17, 9, 31, 5, 43, 12, 67, 23, 101]
        var chunks: [Data] = []
        var startIndex = 0
        var lengthIndex = 0

        while startIndex < data.count {
            let length = lengths[lengthIndex % lengths.count]
            let endIndex = min(startIndex + length, data.count)
            chunks.append(data.subdata(in: startIndex..<endIndex))
            startIndex = endIndex
            lengthIndex += 1
        }
        return chunks
    }

    private static func message(from request: TanyaAIStreamRequest) -> String {
        guard let object = try? JSONSerialization.jsonObject(with: request.body),
              let dictionary = object as? [String: Any],
              let message = dictionary["message"] as? String else {
            return ""
        }
        return message
    }

    private static let chartSeries: [[String: Any]] = [
        ["label": "Fund A", "value": 55, "formattedValue": "55%"],
        ["label": "Fund B", "value": 30, "formattedValue": "30%"],
        ["label": "Cash", "value": 15, "formattedValue": "15%"]
    ]

    private static let spendingSeries: [[String: Any]] = [
        ["label": "Groceries", "value": 420, "formattedValue": "USD 420"],
        ["label": "Transport", "value": 245, "formattedValue": "USD 245"],
        ["label": "Dining", "value": 190, "formattedValue": "USD 190"]
    ]

    private static let approvalSummary: [[String: String]] = [
        ["label": "Recipient", "value": "Demo Recipient"],
        ["label": "Amount", "value": "USD 25.00"],
        ["label": "Source", "value": "Demo account •••• 4821"]
    ]
}
