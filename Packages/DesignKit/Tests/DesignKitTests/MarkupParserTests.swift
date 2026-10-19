//
//  MarkupParserTests.swift
//  DesignKit
//
//  Created by Wendra on 19/10/26.
//

import XCTest

@testable import DesignKit

final class MarkupParserTests: XCTestCase {
    func testUserExampleProducesBoldStrikeLinkAndColor() throws {
        let source =
            "Saya [bold]wendra[/bold], memiliki [strike]uang[/strike] maap maksud saya "
            + "[link]BISA DIKLIK|https://google.com[/link] dengan warna [color]hijau|25C36B[/color]"
        let runs = MarkupParser.runs(from: source)
        XCTAssertEqual(
            runs.map(\.text).joined(), "Saya wendra, memiliki uang maap maksud saya BISA DIKLIK dengan warna hijau")
        XCTAssertEqual(try XCTUnwrap(runs.first { $0.text == "wendra" }).style.isBold, true)
        XCTAssertEqual(try XCTUnwrap(runs.first { $0.text == "uang" }).style.isStruckThrough, true)
        XCTAssertEqual(
            try XCTUnwrap(runs.first { $0.text == "BISA DIKLIK" }).style.link, URL(string: "https://google.com"))
        XCTAssertEqual(try XCTUnwrap(runs.first { $0.text == "hijau" }).style.colorHex, "25C36B")
        XCTAssertEqual(try XCTUnwrap(runs.first { $0.text == "Saya " }).style, MarkupStyle())
    }

    func testStreamingHidesHalfTagsAndNeverLinksAHalfTarget() {
        XCTAssertEqual(MarkupParser.runs(from: "Saya [bo").map(\.text), ["Saya "])
        XCTAssertEqual(MarkupParser.runs(from: "Saya [/bo").map(\.text), ["Saya "])
        let bold = MarkupParser.runs(from: "[bold]wen")
        XCTAssertEqual(bold, [MarkupRun(text: "wen", style: MarkupStyle(isBold: true))])
        let link = MarkupParser.runs(from: "[link]BISA|https://goo")
        XCTAssertEqual(link.map(\.text), ["BISA"])
        XCTAssertNil(link.first?.style.link)
        let color = MarkupParser.runs(from: "[color]hijau|25C")
        XCTAssertEqual(color.map(\.text), ["hijau"])
        XCTAssertNil(color.first?.style.colorHex)
    }

    func testLinkTargetsAcceptWebDeeplinkAndPhoneButRejectUnsafeSchemes() {
        for target in ["https://ocbc.id/promo", "ocbcid://investment", "tel:1500999", "tel://1500999"] {
            XCTAssertEqual(
                MarkupParser.runs(from: "[link]Buka|\(target)[/link]").first?.style.link, URL(string: target))
        }
        for target in ["javascript:alert(1)", "file:///etc/hosts", "data:text/html,x", "bukan url", ""] {
            let runs = MarkupParser.runs(from: "[link]Buka|\(target)[/link]")
            XCTAssertEqual(runs.map(\.text), ["Buka"], target)
            XCTAssertNil(runs.first?.style.link, target)
        }
    }

    func testUnknownTagsAreDroppedAndOrdinaryBracketsStay() {
        XCTAssertEqual(MarkupParser.runs(from: "[italic]miring[/italic]").map(\.text), ["miring"])
        XCTAssertEqual(MarkupParser.runs(from: "Nilai [USD 100] naik").map(\.text), ["Nilai [USD 100] naik"])
        XCTAssertEqual(MarkupParser.runs(from: "tanpa pembuka[/bold] tetap").map(\.text), ["tanpa pembuka tetap"])
    }

    func testNestedTagsCombineStyles() throws {
        let runs = MarkupParser.runs(from: "[bold]Total [color]+3.600.000|25C36B[/color][/bold]")
        let amount = try XCTUnwrap(runs.first { $0.text == "+3.600.000" })
        XCTAssertTrue(amount.style.isBold)
        XCTAssertEqual(amount.style.colorHex, "25C36B")
        XCTAssertTrue(try XCTUnwrap(runs.first { $0.text == "Total " }).style.isBold)
    }
}
