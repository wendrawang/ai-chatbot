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
    let chartType: String
    let series: [TanyaAIChartSeriesDTO]
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
}

struct TanyaAIApprovalDTO: Decodable {
    let messageIdentifier: String
    let approvalIdentifier: String
    let transactionIdentifier: String
    let challengeIdentifier: String
    let title: String
    let summary: [TanyaAIKeyValueDTO]
    let expiresAt: Date
}

struct TanyaAIStatusDTO: Decodable {
    let messageIdentifier: String
    let title: String
    let detail: String
    let level: String
}
