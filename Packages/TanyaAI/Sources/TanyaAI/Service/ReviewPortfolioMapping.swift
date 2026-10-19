//
//  ReviewPortfolioMapping.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import DesignKit
import Foundation

/// `review-porto`: ringkasan evaluasi, tabel produk, dan action lanjutan.
/// DTO sementara sampai kontrak BE final; bentuknya ada di docs/CHAT_CONTRACT.md.
struct ReviewPortfolioMapping: IntentMapping {
    func blocks(from data: Data, locale: Locale) throws -> [ChatBlock] {
        let response = try JSONDecoder().decode(ReviewPortfolioResponse.self, from: data)
        let amount = formatter(locale: locale, isSigned: false)
        let profit = formatter(locale: locale, isSigned: true)
        let table = TableBlock(
            columns: [
                .init(title: String(resource: R.string.localizable.portfolioProduct, locale: locale), isTrailing: nil),
                .init(
                    title: String(resource: R.string.localizable.portfolioCurrentValue, locale: locale),
                    isTrailing: true),
                .init(title: String(resource: R.string.localizable.portfolioProfit, locale: locale), isTrailing: true)
            ],
            rows: response.holdings.map { [$0.product, amount.text($0.currentValue), profit.text($0.profit)] },
            footer: .init(
                label: String(resource: R.string.localizable.portfolioTotalProfit, locale: locale),
                value: profit.text(response.totalProfit)
            )
        )
        var blocks: [ChatBlock] = [.text(response.summary), .table(table)]
        if let actions = response.actions, !actions.isEmpty { blocks.append(.actions(actions)) }
        return blocks
    }
}

/// Bentuk JSON hasil inquiry BE `review-porto` (sementara).
private struct ReviewPortfolioResponse: Decodable {
    let summary: String
    let holdings: [ReviewPortfolioHolding]
    let totalProfit: Decimal
    let actions: [ActionItem]?
}

private struct ReviewPortfolioHolding: Decodable {
    let product: String
    let currentValue: Decimal
    let profit: Decimal
}

// MARK: - Helpers

private extension ReviewPortfolioMapping {
    /// Angka rupiah tanpa desimal dengan pemisah sesuai bahasa (id: 35.000.000).
    func formatter(locale: Locale, isSigned: Bool) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = .zero
        if isSigned { formatter.positivePrefix = formatter.plusSign }
        return formatter
    }
}

private extension NumberFormatter {
    func text(_ value: Decimal) -> String {
        string(from: value as NSDecimalNumber) ?? value.description
    }
}
