import XCTest

@testable import DesignKit

final class DataTableTests: XCTestCase {
    func testRejectsEmptyAndMoreThanThreeColumns() {
        for count in [0, 4] {
            XCTAssertThrowsError(try DataTableData(columns: columns(count: count), rows: [])) { error in
                XCTAssertEqual(error as? DataTableValidationError, .invalidColumnCount(count))
            }
        }
    }

    func testAcceptsOneThroughThreeColumnsWithoutLimitingRows() throws {
        for count in 1...3 {
            let rows = (0..<10).map { _ in DataTableRow(cells: Array(repeating: "value", count: count)) }
            let data = try DataTableData(columns: columns(count: count), rows: rows)
            XCTAssertEqual(data.rows.count, 10)
        }
    }

    func testRejectsMissingAndExtraCellsBeforeRendering() {
        for count in [1, 3] {
            XCTAssertThrowsError(
                try DataTableData(
                    columns: columns(count: 2), rows: [DataTableRow(cells: Array(repeating: "value", count: count))]
                )
            ) { error in
                XCTAssertEqual(
                    error as? DataTableValidationError, .mismatchedCellCount(row: 0, expected: 2, actual: count))
            }
        }
    }

    func testRejectsFooterWithWrongCellCount() {
        XCTAssertThrowsError(
            try DataTableData(
                columns: columns(count: 2), rows: [], footer: DataTableRow(cells: ["Total"])
            )
        ) { error in
            XCTAssertEqual(error as? DataTableValidationError, .mismatchedFooterCount(expected: 2, actual: 1))
        }
    }

    func testRejectsNonPositiveAndNonFiniteWeights() {
        for weight in [0, -1, Double.infinity, Double.nan] {
            XCTAssertThrowsError(
                try DataTableData(columns: [DataTableColumn(title: "Item", widthWeight: weight)], rows: []))
        }
    }

    func testSharedWidthsFitAvailableSpaceAndPreserveRatios() throws {
        let data = try DataTableData(
            columns: [
                DataTableColumn(title: "Item", widthWeight: 2),
                DataTableColumn(title: "Value", alignment: .trailing),
                DataTableColumn(title: "Change", alignment: .trailing)
            ], rows: [])
        let widths = data.columnWidths(availableWidth: 336, spacing: 8)
        XCTAssertEqual(widths, [160, 80, 80])
        XCTAssertEqual(widths.reduce(0, +) + 16, 336)
        XCTAssertTrue(data.columnWidths(availableWidth: 8, spacing: 8).allSatisfy { $0 == 0 })
    }

    func testLargeWeightsDoNotOverflowLayout() throws {
        let data = try DataTableData(
            columns: [
                DataTableColumn(title: "First", widthWeight: .greatestFiniteMagnitude),
                DataTableColumn(title: "Second", widthWeight: .greatestFiniteMagnitude)
            ], rows: [])
        XCTAssertEqual(data.columnWidths(availableWidth: 208, spacing: 8), [100, 100])
    }

    func testRejectsWeightRatiosThatUnderflowAndHideAColumn() {
        XCTAssertThrowsError(
            try DataTableData(
                columns: [
                    DataTableColumn(title: "First", widthWeight: .leastNonzeroMagnitude),
                    DataTableColumn(title: "Second", widthWeight: .greatestFiniteMagnitude)
                ], rows: [])
        ) { error in
            XCTAssertEqual(error as? DataTableValidationError, .invalidColumnWeight(0))
        }
    }

    func testDecoderValidatesColumnAndRowLimits() {
        let invalidColumns = #"{"columns":[{"title":"A"},{"title":"B"},{"title":"C"},{"title":"D"}],"rows":[]}"#
        let invalidRows = #"{"columns":[{"title":"A"},{"title":"B"}],"rows":[{"cells":["only one"]}]}"#
        for json in [invalidColumns, invalidRows] {
            XCTAssertThrowsError(try JSONDecoder().decode(DataTableData.self, from: Data(json.utf8)))
        }
    }

    func testMinimalJSONDefaultsAndRoundTripPreserveTable() throws {
        let json = #"""
            {"columns":[{"title":"Item"},{"title":"Value","alignment":"trailing"}],
             "rows":[{"cells":["Fund","100"]}]}
            """#
        let data = try JSONDecoder().decode(DataTableData.self, from: Data(json.utf8))
        XCTAssertEqual(data.columns[0].alignment, .leading)
        XCTAssertEqual(data.columns[0].widthWeight, 1)
        XCTAssertFalse(data.rows[0].isEmphasized)
        let restored = try JSONDecoder().decode(DataTableData.self, from: JSONEncoder().encode(data))
        XCTAssertEqual(restored, data)
    }

    func testMergedTotalLabelDecodesAndRoundTripsWithoutDroppingValues() throws {
        let json = #"""
            {"columns":[{"title":"Product"},{"title":"Value"},{"title":"Profit","alignment":"trailing"}],
             "rows":[{"cells":["Fund","100","10"]}],
             "footer":{"cells":["Total profit","","10"],"leadingColumnSpan":2}}
            """#
        let data = try JSONDecoder().decode(DataTableData.self, from: Data(json.utf8))
        XCTAssertEqual(data.rows[0].leadingColumnSpan, 1)
        XCTAssertEqual(data.footer?.leadingColumnSpan, 2)
        XCTAssertEqual(data.footer?.cells.last, "10")
        XCTAssertEqual(try JSONDecoder().decode(DataTableData.self, from: JSONEncoder().encode(data)), data)
    }

    func testRejectsSpanOutsideColumnCount() {
        for span in [0, -1, 4] {
            XCTAssertThrowsError(
                try DataTableData(
                    columns: columns(count: 3), rows: [],
                    footer: DataTableRow(cells: ["Total", "", "10"], leadingColumnSpan: span)
                )
            ) { error in
                XCTAssertEqual(error as? DataTableValidationError, .invalidColumnSpan(row: 0, span: span))
            }
        }
    }

    func testMergedCellsCannotSilentlyHideNonEmptyValues() {
        XCTAssertThrowsError(
            try DataTableData(
                columns: columns(count: 3),
                rows: [DataTableRow(cells: ["Total", "must remain visible", "10"], leadingColumnSpan: 2)]
            )
        ) { error in
            XCTAssertEqual(error as? DataTableValidationError, .invalidColumnSpan(row: 0, span: 2))
        }
    }

    private func columns(count: Int) -> [DataTableColumn] {
        (0..<count).map { DataTableColumn(title: "Column \($0)") }
    }
}
