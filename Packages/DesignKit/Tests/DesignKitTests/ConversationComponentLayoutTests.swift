import SwiftUI
import XCTest

@testable import DesignKit

@MainActor
final class ConversationComponentLayoutTests: XCTestCase {
    func testTableWrapsLongCellAndKeepsAllThreeColumns() throws {
        let longName = String(repeating: "Long product name ", count: 6)
        let data = try DataTableData(
            columns: [
                DataTableColumn(title: "Product", widthWeight: 2),
                DataTableColumn(title: "Value", alignment: .trailing),
                DataTableColumn(title: "Change", alignment: .trailing)
            ], rows: [DataTableRow(cells: [longName, "1.000.000", "+10%"])])
        let short = try DataTableData(columns: data.columns, rows: [DataTableRow(cells: ["Fund", "100", "+1%"])])
        let longSize = fittedSize(DataTable(data: data), width: 320)
        let shortSize = fittedSize(DataTable(data: short), width: 320)
        XCTAssertLessThanOrEqual(longSize.width, 320)
        XCTAssertGreaterThan(longSize.height, shortSize.height)
    }

    func testSelectedOptionsRemainRenderedInHistory() {
        let options = [
            SelectionOption(identifier: "first", title: "First option"),
            SelectionOption(identifier: "second", title: "Second option")
        ]
        let initial = OptionList(title: nil, options: options) { _ in }
        let selected = OptionList(title: nil, options: options, selectedIdentifier: "first", isEnabled: false) { _ in }
        let initialSize = fittedSize(initial, width: 320)
        let selectedSize = fittedSize(selected, width: 320)
        XCTAssertGreaterThan(selectedSize.height, DesignKitMetrics.Size.minimumTapTarget)
        XCTAssertEqual(selectedSize.height, initialSize.height, accuracy: 1)
        XCTAssertEqual(selected.options, initial.options)
    }

    private func fittedSize<Content: View>(_ content: Content, width: CGFloat) -> CGSize {
        let controller = UIHostingController(rootView: content)
        controller.view.bounds = CGRect(x: 0, y: 0, width: width, height: 1_000)
        controller.view.layoutIfNeeded()
        return controller.sizeThatFits(in: CGSize(width: width, height: 10_000))
    }
}
