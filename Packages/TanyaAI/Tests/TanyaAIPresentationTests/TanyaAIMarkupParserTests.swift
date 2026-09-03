import XCTest
@testable import TanyaAIPresentation

/// The wire format is a closed tag set, so these tests pin both what it
/// supports and what it refuses to do.
final class TanyaAIMarkupParserTests: XCTestCase {
    func testBoldTagStylesOnlyItsOwnText() {
        let runs = TanyaAIMarkupParser.runs(from: "saya [bold]wen[/bold] ganteng")

        XCTAssertEqual(runs.map(\.text), ["saya ", "wen", " ganteng"])
        XCTAssertEqual(runs.map(\.style.isBold), [false, true, false])
    }

    func testStrikeTagIsStruckThrough() {
        let runs = TanyaAIMarkupParser.runs(from: "[strike]wen[/strike]")

        XCTAssertEqual(runs.count, 1)
        XCTAssertTrue(runs[0].style.isStruckThrough)
    }

    func testColorTagKeepsTheTextAndStripsTheValue() {
        let runs = TanyaAIMarkupParser.runs(from: "[color]wen|25C36B[/color]")

        XCTAssertEqual(runs.map(\.text), ["wen"])
        XCTAssertEqual(runs[0].style.colorHex, "25C36B")
    }

    func testInvalidColorValueLeavesTheTextAlone() {
        let runs = TanyaAIMarkupParser.runs(from: "[color]wen|nothex[/color]")

        XCTAssertEqual(runs.map(\.text), ["wen|nothex"])
        XCTAssertNil(runs[0].style.colorHex)
    }

    func testNestedTagsCombine() {
        let runs = TanyaAIMarkupParser.runs(
            from: "[bold][color]wen|25C36B[/color][/bold]"
        )

        XCTAssertEqual(runs.map(\.text), ["wen"])
        XCTAssertTrue(runs[0].style.isBold)
        XCTAssertEqual(runs[0].style.colorHex, "25C36B")
    }

    /// A backend that ships a tag before the app supports it should degrade to
    /// plain text, not show markup to the customer.
    func testUnknownTagIsDroppedButItsTextSurvives() {
        let runs = TanyaAIMarkupParser.runs(
            from: "[underline]wen[/underline] ok"
        )

        XCTAssertEqual(runs.map(\.text), ["wen", " ok"])
        XCTAssertTrue(runs.allSatisfy { $0.style.isPlain })
    }

    /// Text arrives in chunks, so an open tag styles what has arrived so far.
    func testUnclosedTagStillStylesTheRemainder() {
        let runs = TanyaAIMarkupParser.runs(from: "saya [bold]wen")

        XCTAssertEqual(runs.map(\.text), ["saya ", "wen"])
        XCTAssertEqual(runs.map(\.style.isBold), [false, true])
    }

    /// A tag that is still arriving must not flash as raw markup.
    func testHalfArrivedTagAtTheEndIsHidden() {
        let runs = TanyaAIMarkupParser.runs(from: "saya [bo")

        XCTAssertEqual(runs.map(\.text), ["saya "])
    }

    func testStrayBracketStaysLiteral() {
        let runs = TanyaAIMarkupParser.runs(from: "biaya [1] gratis")

        XCTAssertEqual(runs.map(\.text), ["biaya [1] gratis"])
    }

    /// Asterisks are ordinary characters here - the reason for not using
    /// Markdown in the first place.
    func testAsterisksAreNotStyling() {
        let runs = TanyaAIMarkupParser.runs(from: "kartu **** 1234 *syarat")

        XCTAssertEqual(runs.map(\.text), ["kartu **** 1234 *syarat"])
        XCTAssertTrue(runs.allSatisfy { $0.style.isPlain })
    }

    func testMismatchedClosingTagKeepsTheContent() {
        let runs = TanyaAIMarkupParser.runs(from: "[bold]wen[/strike] ok")

        XCTAssertEqual(runs.map(\.text).joined(), "wen ok")
    }

    /// Only a fragment shaped like a tag is treated as one still arriving.
    /// An unclosed bracket in ordinary copy keeps the rest of the message.
    func testUnclosedBracketInOrdinaryCopyKeepsTheText() {
        let runs = TanyaAIMarkupParser.runs(from: "Nilai [USD 100 per hari")

        XCTAssertEqual(runs.map(\.text).joined(), "Nilai [USD 100 per hari")
    }

    func testHalfArrivedTagIsStillHidden() {
        let runs = TanyaAIMarkupParser.runs(from: "saya [bo")

        XCTAssertEqual(runs.map(\.text).joined(), "saya ")
    }
}
