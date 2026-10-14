import SwiftUI
import XCTest

@testable import DesignKit

extension ComponentLayoutStressTests {
    func testAllNativeComponentsWrapAtNarrowWidthsAndLargestDynamicType() throws {
        let components = try stressComponents()
        for width: CGFloat in [320, 375, 430, 768] {
            for (name, content) in components {
                let normal = size(content: content, width: width, category: .large)
                let large = size(content: content, width: width, category: .accessibilityExtraExtraExtraLarge)
                XCTAssertLessThanOrEqual(normal.width, width + 1, name)
                XCTAssertLessThanOrEqual(large.width, width + 1, name)
                XCTAssertTrue(large.height.isFinite && large.height > 0 && large.height < 10_000, name)
                XCTAssertGreaterThanOrEqual(large.height + 1, normal.height, name)
            }
        }
    }

    private func size(content: AnyView, width: CGFloat, category: ContentSizeCategory) -> CGSize {
        let root = content.theme(.sandbox).environment(\.sizeCategory, category)
        let controller = UIHostingController(rootView: root)
        controller.view.bounds = CGRect(x: 0, y: 0, width: width, height: 1_000)
        controller.view.layoutIfNeeded()
        return controller.sizeThatFits(in: CGSize(width: width, height: 10_000))
    }

    private func stressComponents() throws -> [(String, AnyView)] {
        let longText = String(repeating: "A long display title that wraps onto several lines. ", count: 4)
        let code = "ABCDEFGHIJKLMNOPQRSTUVWXYZ12345678901234567890"
        let table = try DataTableData(
            columns: [
                DataTableColumn(title: "Item title", widthWeight: 1.4),
                DataTableColumn(title: "Current value (IDR)", alignment: .trailing),
                DataTableColumn(title: "Change (IDR)", alignment: .trailing)
            ], rows: [DataTableRow(cells: [longText, "123.456.789.012,34", "+12.345.678 (+12,34%)"])],
            footer: DataTableRow(cells: ["Combined total", "", "123.456.789.012,34"], leadingColumnSpan: 2)
        )
        let options = [
            SelectionOption(identifier: "first", title: longText),
            SelectionOption(identifier: "second", title: code)
        ]
        return [
            ("table", AnyView(DataTable(data: table))),
            (
                "summary",
                AnyView(
                    SummaryCard(fields: [SummaryField(label: longText, value: code)]) {
                        ItemHeader(title: longText, subtitle: longText, detail: code, symbolName: "doc")
                    })
            ),
            ("metric", AnyView(MetricSummary(title: longText, value: "123.456.789.012,34", change: longText))),
            (
                "options",
                AnyView(
                    OptionList(
                        title: longText, options: options,
                        selectedIdentifier: "first", isEnabled: false, maximumWidth: nil
                    ) { _ in })
            ),
            ("acknowledgement", AnyView(AcknowledgementRow(title: longText, isAccepted: true) {})),
            ("action", AnyView(ActionPill(title: longText, symbolName: "arrow.turn.down.right") {})),
            ("rich text", AnyView(TextBubble(text: "• [bold]Title:[/bold] " + longText + code, isUser: false))),
            (
                "welcome action",
                AnyView(
                    QuickActionRow(
                        action: QuickActionData(
                            identifier: "first",
                            title: longText, subtitle: code, symbolName: "doc")
                    ) { _ in })
            )
        ]
    }
}
