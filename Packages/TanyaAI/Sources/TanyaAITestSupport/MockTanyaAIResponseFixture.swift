import Foundation
import TanyaAIContracts

enum MockTanyaAIResponseFixture {
    typealias ContentEvent = (name: String, payload: [String: Any])

    static func chunks(for request: TanyaAIStreamRequest) -> [Data] {
        let prompt = message(from: request).lowercased()
        let identifier = request.requestIdentifier.lowercased()

        if prompt.contains("showcase") {
            return MockTanyaAIShowcaseFixture.chunks(identifier: identifier)
        }
        if prompt.contains("deeplink") {
            return MockTanyaAIDeeplinkFixture.chunks(identifier: identifier)
        }
        if prompt.contains("stress") {
            return MockTanyaAIStressFixture.chunks(identifier: identifier)
        }
        if prompt.contains("conversion") || prompt.contains("currency") {
            return MockTanyaAIConfirmationFixture.conversionChunks(identifier)
        }
        if prompt.contains("deposit") {
            return MockTanyaAIConfirmationFixture.depositChunks(identifier)
        }
        if prompt.contains("saving") {
            return MockTanyaAIConfirmationFixture.savingsChunks(identifier)
        }
        if prompt.contains("incoming") {
            return MockTanyaAIInsightFixture.incomingChunks(identifier)
        }
        if prompt.contains("bill") {
            return MockTanyaAIInsightFixture.billsChunks(identifier)
        }
        if prompt.contains("spending") {
            return MockTanyaAIInsightFixture.spendingChunks(identifier)
        }
        if prompt.contains("limit") {
            return MockTanyaAIInsightFixture.informationChunks(identifier)
        }
        if prompt.contains("transfer") {
            return MockTanyaAIConfirmationFixture.transferChunks(identifier)
        }
        return MockTanyaAIInsightFixture.portfolioChunks(identifier)
    }

    static func responseChunks(
        identifier: String,
        text: String,
        contents: [ContentEvent],
        suggestions: [[String: String]]
    ) -> [Data] {
        let textIdentifier = "text-\(identifier)"
        var events = [
            event(
                "response.started",
                ["messageIdentifier": textIdentifier]
            ),
            event(
                "text.delta",
                ["messageIdentifier": textIdentifier, "text": text]
            )
        ]
        events.append(contentsOf: contentEvents(contents, identifier: identifier))
        events.append(
            event("response.suggestions", ["suggestions": suggestions])
        )
        events.append(
            event(
                "response.completed",
                ["messageIdentifier": textIdentifier]
            )
        )
        return irregularChunks(from: events.joined())
    }

    static func contentEvent(
        _ name: String,
        prefix: String,
        identifier: String,
        payload: [String: Any]
    ) -> String {
        var content = payload
        content["messageIdentifier"] = "\(prefix)-\(identifier)"
        return event(name, content)
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

    private static func contentEvents(
        _ contents: [ContentEvent],
        identifier: String
    ) -> [String] {
        contents.enumerated().map { index, content in
            contentEvent(
                content.name,
                prefix: "content-\(index)",
                identifier: identifier,
                payload: content.payload
            )
        }
    }

    private static func message(from request: TanyaAIStreamRequest) -> String {
        guard let object = try? JSONSerialization.jsonObject(with: request.body),
              let dictionary = object as? [String: Any],
              let message = dictionary["message"] as? String else {
            return ""
        }
        return message
    }
}
