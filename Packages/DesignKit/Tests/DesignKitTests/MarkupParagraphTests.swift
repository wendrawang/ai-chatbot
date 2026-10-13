import XCTest

@testable import DesignKit

final class MarkupParagraphTests: XCTestCase {
    func testBulletMarkersAreSeparatedFromTheStyledBody() {
        let runs = MarkupParser.runs(
            from: "Detail:\n• [bold]Tabungan:[/bold] IDR 45.000.000\n- Deposito: IDR 55.000.000"
        )
        let paragraphs = MarkupParser.paragraphs(from: runs)

        XCTAssertEqual(paragraphs.map(\.marker), [nil, "•", "•"])
        XCTAssertEqual(paragraphs[1].runs.map(\.text).joined(), "Tabungan: IDR 45.000.000")
        XCTAssertTrue(paragraphs[1].runs.first?.style.isBold == true)
        XCTAssertEqual(paragraphs[2].runs.map(\.text).joined(), "Deposito: IDR 55.000.000")
    }

    func testNumberedListsSupportBothMarkerForms() {
        let paragraphs = MarkupParser.paragraphs(from: MarkupParser.runs(from: "1. Satu\n2) Dua\n100. Seratus"))

        XCTAssertEqual(paragraphs.map(\.marker), ["1.", "2)", "100."])
        XCTAssertEqual(paragraphs.map { $0.runs.map(\.text).joined() }, ["Satu", "Dua", "Seratus"])
    }

    func testIndentedContinuationStaysInBulletWithItsLinkStyle() {
        let paragraphs = MarkupParser.paragraphs(
            from: MarkupParser.runs(from: "• Produk panjang\n  [link]ocbcid://product|Lihat produk[/link]\n• Lainnya")
        )

        XCTAssertEqual(paragraphs.count, 2)
        XCTAssertEqual(paragraphs[0].runs.map(\.text).joined(), "Produk panjang\nLihat produk")
        XCTAssertEqual(paragraphs[0].runs.last?.style.linkURL?.absoluteString, "ocbcid://product")
    }

    func testParagraphBreaksAndLiteralSymbolsArePreserved() {
        let paragraphs = MarkupParser.paragraphs(
            from: MarkupParser.runs(from: "kartu **** 1234\n\n1.25% per tahun\n-10%")
        )

        XCTAssertEqual(paragraphs.count, 4)
        XCTAssertTrue(paragraphs.allSatisfy { $0.marker == nil })
        XCTAssertEqual(
            paragraphs.map { $0.runs.map(\.text).joined() }, ["kartu **** 1234", "", "1.25% per tahun", "-10%"])
    }

    func testPrefixCrossingStyleRunsDoesNotRemoveBodyFormatting() {
        let paragraphs = MarkupParser.paragraphs(from: MarkupParser.runs(from: "[bold]• Tabungan[/bold]: sehat"))

        XCTAssertEqual(paragraphs.first?.marker, "•")
        XCTAssertEqual(paragraphs.first?.runs.map(\.text).joined(), "Tabungan: sehat")
        XCTAssertTrue(paragraphs.first?.runs.first?.style.isBold == true)
    }
}
