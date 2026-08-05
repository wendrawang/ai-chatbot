import Foundation
import TanyaAIDomain

final class TanyaAIStreamEventDecoder {
    let decoder: JSONDecoder

    init() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func decode(_ event: TanyaAISSEEvent) throws -> TanyaAIStreamEvent? {
        switch event.name {
        case "response.started":
            return try decodeStarted(event.data)
        case "text.delta":
            return try decodeText(event.data)
        case "content.information":
            return try decodeInformation(event.data)
        case "content.chart":
            return try decodeChart(event.data)
        case "content.portfolio":
            return try decodePortfolio(event.data)
        case "content.financial-list":
            return try decodeFinancialList(event.data)
        case "content.approval":
            return try decodeApproval(event.data)
        case "content.receipt":
            return try decodeReceipt(event.data)
        case "content.status":
            return try decodeStatus(event.data)
        case "response.suggestions":
            return try decodeSuggestions(event.data)
        case "response.completed":
            return try decodeCompleted(event.data)
        case "heartbeat":
            return .heartbeat
        default:
            return try decodeUnknown(event)
        }
    }

    private func decodeUnknown(
        _ event: TanyaAISSEEvent
    ) throws -> TanyaAIStreamEvent? {
        guard event.name.hasPrefix("content.") else {
            return nil
        }
        let payload = try decoder.decode(
            TanyaAIUnsupportedContentDTO.self,
            from: event.data
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
