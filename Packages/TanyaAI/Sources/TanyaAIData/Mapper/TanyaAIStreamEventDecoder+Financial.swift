import DesignKit
import Foundation
import TanyaAIDomain

extension TanyaAIStreamEventDecoder {
    func decodeFinancialList(_ data: Data) throws -> TanyaAIStreamEvent {
        let payload = try decoder.decode(
            TanyaAIFinancialListDTO.self,
            from: data
        )
        let style = FinancialListPayload.Style(
            rawValue: payload.style
        ) ?? .paidBills
        let content = FinancialListPayload(
            title: payload.title,
            style: style,
            rows: payload.rows.map(makeFinancialRow),
            totalLabel: payload.totalLabel,
            totalValue: payload.totalValue,
            totalCaption: payload.totalCaption,
            footnote: payload.footnote
        )
        return .content(
            messageIdentifier: payload.messageIdentifier,
            content: .financialList(content)
        )
    }

    func decodeReceipt(_ data: Data) throws -> TanyaAIStreamEvent {
        let payload = try decoder.decode(TanyaAIReceiptDTO.self, from: data)
        let content = ReceiptPayload(
            title: payload.title,
            detail: payload.detail,
            summary: payload.summary.map {
                KeyValue(label: $0.label, value: $0.value)
            },
            footnote: payload.footnote
        )
        return .content(
            messageIdentifier: payload.messageIdentifier,
            content: .receipt(content)
        )
    }

    func decodeSuggestions(_ data: Data) throws -> TanyaAIStreamEvent {
        let payload = try decoder.decode(TanyaAISuggestionsDTO.self, from: data)
        let suggestions = payload.suggestions.map {
            TanyaAISuggestionPayload(
                identifier: $0.identifier,
                title: $0.title,
                prompt: $0.prompt
            )
        }
        return .suggestions(suggestions)
    }

    private func makeFinancialRow(
        _ row: TanyaAIFinancialListRowDTO
    ) -> FinancialListRow {
        FinancialListRow(
            title: row.title,
            subtitle: row.subtitle,
            value: row.value,
            detail: row.detail,
            tone: FinancialListRow.Tone(
                rawValue: row.tone ?? "neutral"
            ) ?? .neutral
        )
    }
}
