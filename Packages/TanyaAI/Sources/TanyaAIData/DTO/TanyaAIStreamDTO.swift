import Foundation

struct TanyaAIMessageIdentifierDTO: Decodable {
    let messageIdentifier: String
}

struct TanyaAITextDeltaDTO: Decodable {
    let messageIdentifier: String
    let text: String
}

struct TanyaAIInformationDTO: Decodable {
    let messageIdentifier: String
    let title: String?
    let text: String
    let items: [TanyaAIKeyValueDTO]
}

struct TanyaAIKeyValueDTO: Decodable {
    let label: String
    let value: String
}

struct TanyaAIChartDTO: Decodable {
    let messageIdentifier: String
    let title: String
    let subtitle: String?
    let totalValue: String?
    let chartType: String
    let series: [TanyaAIChartSeriesDTO]
    let footnote: String?
}

struct TanyaAIChartSeriesDTO: Decodable {
    let label: String
    let value: Double
    let formattedValue: String
}

struct TanyaAIPortfolioDTO: Decodable {
    let messageIdentifier: String
    let title: String
    let totalValue: String
    let performanceText: String
    let allocations: [TanyaAIChartSeriesDTO]
    let footnote: String?
}

struct TanyaAIActionDTO: Decodable {
    let identifier: String
    let deeplink: String
}

struct TanyaAIActionButtonDTO: Decodable {
    let title: String
    let style: String?
    let action: TanyaAIActionDTO
}

struct TanyaAIActionsDTO: Decodable {
    let messageIdentifier: String
    let title: String?
    let detail: String?
    let actions: [TanyaAIActionButtonDTO]
}

struct TanyaAIApprovalDTO: Decodable {
    let messageIdentifier: String
    let approvalIdentifier: String
    let transactionIdentifier: String
    let challengeIdentifier: String
    let kind: String?
    let title: String
    let summary: [TanyaAIKeyValueDTO]
    let notice: String?
    let expiresAt: Date
    let handoff: TanyaAIActionDTO?
}

struct TanyaAIFinancialListDTO: Decodable {
    let messageIdentifier: String
    let title: String
    let style: String
    let rows: [TanyaAIFinancialListRowDTO]
    let totalLabel: String?
    let totalValue: String?
    let totalCaption: String?
    let footnote: String?
}

struct TanyaAIFinancialListRowDTO: Decodable {
    let title: String
    let subtitle: String?
    let value: String
    let detail: String?
    let tone: String?
}

struct TanyaAIReceiptDTO: Decodable {
    let messageIdentifier: String
    let title: String
    let detail: String
    let summary: [TanyaAIKeyValueDTO]
    let footnote: String?
}

struct TanyaAISuggestionsDTO: Decodable {
    let suggestions: [TanyaAISuggestionDTO]
}

struct TanyaAISuggestionDTO: Decodable {
    let identifier: String
    let title: String
    let prompt: String
}

struct TanyaAIStatusDTO: Decodable {
    let messageIdentifier: String
    let title: String
    let detail: String
    let level: String
}

struct TanyaAIUnsupportedContentDTO: Decodable {
    let messageIdentifier: String
    let fallbackText: String?
}
