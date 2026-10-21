//
//  ReviewPortfolioMappingTests.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import XCTest

@testable import TanyaAI

final class ReviewPortfolioMappingTests: XCTestCase {
    private let response = Data(
        #"""
        {"summary":"[bold]Evaluasi:[/bold] defensif",
         "holdings":[{"product":"Reksa Dana","currentValue":35000000,"profit":1200000}],
         "totalProfit":3600000,
         "actions":[{"label":"Optimalkan","style":"chip","action":{"type":"prompt","value":"Optimalkan"}}]}
        """#.utf8)

    func testBackendResultBecomesTextTableAndActionsWithLocalizedNumbers() throws {
        let blocks = try ReviewPortfolioMapping().blocks(from: response, locale: Locale(identifier: "id"))
        XCTAssertEqual(blocks.count, 3)
        XCTAssertEqual(blocks.first, .text("[bold]Evaluasi:[/bold] defensif"))
        guard case .table(let table) = blocks[1] else { return XCTFail("Bukan tabel") }
        XCTAssertEqual(table.columns.map(\.title), ["Produk", "Nilai Saat ini (IDR)", "Keuntungan (IDR)"])
        XCTAssertEqual(table.rows, [["Reksa Dana", "35.000.000", "+1.200.000"]])
        XCTAssertEqual(table.footer, TableBlock.Footer(label: "Total Keuntungan (IDR)", value: "+3.600.000"))
        let english = try ReviewPortfolioMapping().blocks(from: response, locale: Locale(identifier: "en"))
        guard case .table(let englishTable) = english[1] else { return XCTFail("Bukan tabel") }
        XCTAssertEqual(englishTable.rows.first?[1], "35,000,000")
    }

    func testOnlyKnownIntentsHaveAMapping() {
        XCTAssertNotNil(IntentMappings.mapping(for: "review-porto"))
        XCTAssertNil(IntentMappings.mapping(for: "beli-valas"))
    }
}
