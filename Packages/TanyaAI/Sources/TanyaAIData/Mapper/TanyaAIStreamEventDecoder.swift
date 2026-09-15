import DesignKit
import Foundation
import TanyaAIDomain

final class TanyaAIStreamEventDecoder {
    let decoder: JSONDecoder

    init() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func decode(name: String, json: Data) throws -> TanyaAIStreamEvent? {
        if let content = try decodeContent(name: name, json: json) {
            return content
        }
        return try decodeLifecycle(name: name, json: json)
    }

    /// Bubble payloads. Returns `nil` for any other event name, including a
    /// `content.*` this version does not know - `decodeLifecycle` sends that
    /// on to `decodeUnknown`, which degrades it to an unsupported bubble.
    ///
    /// Split in two because one switch over every card is one branch past
    /// what the linter allows, and because the halves are genuinely different
    /// kinds of thing: what a conversation shows, and what money looks like.
    private func decodeContent(
        name: String,
        json: Data
    ) throws -> TanyaAIStreamEvent? {
        if let event = try decodeConversationContent(name: name, json: json) {
            return event
        }
        return try decodeFinancialContent(name: name, json: json)
    }

    private func decodeConversationContent(
        name: String,
        json: Data
    ) throws -> TanyaAIStreamEvent? {
        switch name {
        case "content.image":
            return try decodeImage(json)
        case "content.choices":
            return try decodeChoices(json)
        case "content.live-agent":
            return try decodeLiveAgent(json)
        case "content.html":
            return try decodeHTML(json)
        case "content.information":
            return try decodeInformation(json)
        case "content.status":
            return try decodeStatus(json)
        case "content.actions":
            return try decodeActions(json)
        default:
            return nil
        }
    }

    private func decodeFinancialContent(
        name: String,
        json: Data
    ) throws -> TanyaAIStreamEvent? {
        switch name {
        case "content.chart":
            return try decodeChart(json)
        case "content.portfolio":
            return try decodePortfolio(json)
        case "content.financial-list":
            return try decodeFinancialList(json)
        case "content.approval":
            return try decodeApproval(json)
        case "content.receipt":
            return try decodeReceipt(json)
        default:
            return nil
        }
    }

    /// Everything that frames a response rather than filling it.
    private func decodeLifecycle(
        name: String,
        json: Data
    ) throws -> TanyaAIStreamEvent? {
        switch name {
        case "response.started":
            return try decodeStarted(json)
        case "text.delta":
            return try decodeText(json)
        case "response.suggestions":
            return try decodeSuggestions(json)
        case "response.completed":
            return try decodeCompleted(json)
        case "heartbeat":
            return .heartbeat
        default:
            return try decodeUnknown(name: name, json: json)
        }
    }

    private func decodeUnknown(
        name: String,
        json: Data
    ) throws -> TanyaAIStreamEvent? {
        guard name.hasPrefix("content.") else {
            return nil
        }
        let payload = try decoder.decode(
            TanyaAIUnsupportedContentDTO.self,
            from: json
        )
        let message = payload.fallbackText
            ?? "This content requires a newer app version."
        return .content(
            messageIdentifier: payload.messageIdentifier,
            content: .unsupported(message)
        )
    }

    private func decodeStarted(_ data: Data) throws -> TanyaAIStreamEvent {
        let payload = try decoder.decode(TanyaAIMessageIdentifierDTO.self, from: data)
        return .responseStarted(messageIdentifier: payload.messageIdentifier)
    }

    private func decodeText(_ data: Data) throws -> TanyaAIStreamEvent {
        let payload = try decoder.decode(TanyaAITextDeltaDTO.self, from: data)
        return .textDelta(
            messageIdentifier: payload.messageIdentifier,
            text: payload.text
        )
    }

    private func decodeInformation(_ data: Data) throws -> TanyaAIStreamEvent {
        let payload = try decoder.decode(TanyaAIInformationDTO.self, from: data)
        var blocks: [InformationBlock] = [.text(payload.text)]
        if !payload.items.isEmpty {
            blocks.append(.keyValue(payload.items.map(makeKeyValue)))
        }
        let content = InformationPayload(
            title: payload.title,
            blocks: blocks
        )
        return .content(
            messageIdentifier: payload.messageIdentifier,
            content: .information(content)
        )
    }

    private func decodeChart(_ data: Data) throws -> TanyaAIStreamEvent {
        let payload = try decoder.decode(TanyaAIChartDTO.self, from: data)
        let chartType = ChartPayload.ChartType(
            rawValue: payload.chartType
        ) ?? .bar
        let chart = ChartPayload(
            title: payload.title,
            subtitle: payload.subtitle,
            totalValue: payload.totalValue,
            chartType: chartType,
            series: payload.series.map(makeChartSeries),
            footnote: payload.footnote
        )
        return .content(
            messageIdentifier: payload.messageIdentifier,
            content: .chart(chart)
        )
    }

    private func decodePortfolio(_ data: Data) throws -> TanyaAIStreamEvent {
        let payload = try decoder.decode(TanyaAIPortfolioDTO.self, from: data)
        let portfolio = PortfolioPayload(
            title: payload.title,
            totalValue: payload.totalValue,
            performanceText: payload.performanceText,
            allocations: payload.allocations.map(makeChartSeries),
            footnote: payload.footnote
        )
        return .content(
            messageIdentifier: payload.messageIdentifier,
            content: .portfolio(portfolio)
        )
    }

    private func decodeApproval(_ data: Data) throws -> TanyaAIStreamEvent {
        let payload = try decoder.decode(TanyaAIApprovalDTO.self, from: data)
        let approval = ApprovalPayload(
            approvalIdentifier: payload.approvalIdentifier,
            transactionIdentifier: payload.transactionIdentifier,
            challengeIdentifier: payload.challengeIdentifier,
            kind: ApprovalPayload.Kind(
                rawValue: payload.kind ?? "generic"
            ) ?? .generic,
            title: payload.title,
            summary: payload.summary.map(makeKeyValue),
            notice: payload.notice,
            expiresAt: payload.expiresAt,
            handoff: payload.handoff.map(makeAction),
            state: .awaitingApproval
        )
        return .content(
            messageIdentifier: payload.messageIdentifier,
            content: .approval(approval)
        )
    }

    private func decodeStatus(_ data: Data) throws -> TanyaAIStreamEvent {
        let payload = try decoder.decode(TanyaAIStatusDTO.self, from: data)
        let level = StatusPayload.Level(rawValue: payload.level) ?? .neutral
        let status = StatusPayload(
            title: payload.title,
            detail: payload.detail,
            level: level
        )
        return .content(
            messageIdentifier: payload.messageIdentifier,
            content: .status(status)
        )
    }

    private func decodeCompleted(_ data: Data) throws -> TanyaAIStreamEvent {
        let payload = try decoder.decode(TanyaAIMessageIdentifierDTO.self, from: data)
        return .responseCompleted(messageIdentifier: payload.messageIdentifier)
    }

    private func makeKeyValue(_ item: TanyaAIKeyValueDTO) -> KeyValue {
        KeyValue(label: item.label, value: item.value)
    }

    private func makeChartSeries(
        _ item: TanyaAIChartSeriesDTO
    ) -> ChartSeries {
        ChartSeries(
            label: item.label,
            value: item.value,
            formattedValue: item.formattedValue
        )
    }
}
