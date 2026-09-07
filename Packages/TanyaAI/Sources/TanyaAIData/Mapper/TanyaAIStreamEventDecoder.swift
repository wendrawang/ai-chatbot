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
    private func decodeContent(
        name: String,
        json: Data
    ) throws -> TanyaAIStreamEvent? {
        switch name {
        case "content.information":
            return try decodeInformation(json)
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
        case "content.actions":
            return try decodeActions(json)
        case "content.status":
            return try decodeStatus(json)
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
        var blocks: [TanyaAIInformationBlock] = [.text(payload.text)]
        if !payload.items.isEmpty {
            blocks.append(.keyValue(payload.items.map(makeKeyValue)))
        }
        let content = TanyaAIInformationPayload(
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
        let chartType = TanyaAIChartPayload.ChartType(
            rawValue: payload.chartType
        ) ?? .bar
        let chart = TanyaAIChartPayload(
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
        let portfolio = TanyaAIPortfolioPayload(
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
        let approval = TanyaAIApprovalPayload(
            approvalIdentifier: payload.approvalIdentifier,
            transactionIdentifier: payload.transactionIdentifier,
            challengeIdentifier: payload.challengeIdentifier,
            kind: TanyaAIApprovalPayload.Kind(
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
        let level = TanyaAIStatusPayload.Level(rawValue: payload.level) ?? .neutral
        let status = TanyaAIStatusPayload(
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

    private func makeKeyValue(_ item: TanyaAIKeyValueDTO) -> TanyaAIKeyValue {
        TanyaAIKeyValue(label: item.label, value: item.value)
    }

    private func makeChartSeries(
        _ item: TanyaAIChartSeriesDTO
    ) -> TanyaAIChartSeries {
        TanyaAIChartSeries(
            label: item.label,
            value: item.value,
            formattedValue: item.formattedValue
        )
    }
}
