import XCTest
@testable import DesignKit

/// The wire format is a closed tag set, so these tests pin both what it
/// supports and what it refuses to do.
final class MarkupParserTests: XCTestCase {
    func testBoldTagStylesOnlyItsOwnText() {
        let runs = MarkupParser.runs(from: "saya [bold]wen[/bold] ganteng")

        XCTAssertEqual(runs.map(\.text), ["saya ", "wen", " ganteng"])
        XCTAssertEqual(runs.map(\.style.isBold), [false, true, false])
    }

    func testItalicTagIsItalicised() {
        let runs = MarkupParser.runs(from: "[italic]wen[/italic]")

        XCTAssertEqual(runs.count, 1)
        XCTAssertTrue(runs[0].style.isItalic)
    }

    func testUnderlineTagIsUnderlined() {
        let runs = MarkupParser.runs(from: "[underline]wen[/underline]")

        XCTAssertEqual(runs.count, 1)
        XCTAssertTrue(runs[0].style.isUnderlined)
    }

    /// The four weights stack rather than replace one another, so a phrase can
    /// be bold and underlined at once.
    func testStylesNest() {
        let runs = MarkupParser.runs(
            from: "[bold][underline]wen[/underline][/bold]"
        )

        XCTAssertEqual(runs.count, 1)
        XCTAssertTrue(runs[0].style.isBold)
        XCTAssertTrue(runs[0].style.isUnderlined)
    }

    func testStrikeTagIsStruckThrough() {
        let runs = MarkupParser.runs(from: "[strike]wen[/strike]")

        XCTAssertEqual(runs.count, 1)
        XCTAssertTrue(runs[0].style.isStruckThrough)
    }

    func testColorTagKeepsTheTextAndStripsTheValue() {
        let runs = MarkupParser.runs(from: "[color]wen|25C36B[/color]")

        XCTAssertEqual(runs.map(\.text), ["wen"])
        XCTAssertEqual(runs[0].style.colorHex, "25C36B")
    }

    func testInvalidColorValueLeavesTheTextAlone() {
        let runs = MarkupParser.runs(from: "[color]wen|nothex[/color]")

        XCTAssertEqual(runs.map(\.text), ["wen|nothex"])
        XCTAssertNil(runs[0].style.colorHex)
    }

    func testNestedTagsCombine() {
        let runs = MarkupParser.runs(
            from: "[bold][color]wen|25C36B[/color][/bold]"
        )

        XCTAssertEqual(runs.map(\.text), ["wen"])
        XCTAssertTrue(runs[0].style.isBold)
        XCTAssertEqual(runs[0].style.colorHex, "25C36B")
    }

    /// A backend that ships a tag before the app supports it should degrade to
    /// plain text, not show markup to the customer.
    /// The example has to be a tag the set does not contain, so it changes
    /// whenever the set grows - it was `[underline]` until underline became
    /// real. The property it pins does not change: a backend shipping a style
    /// this version has never heard of degrades to plain text rather than
    /// showing raw markup to the customer.
    func testUnknownTagIsDroppedButItsTextSurvives() {
        let runs = MarkupParser.runs(
            from: "[blink]wen[/blink] ok"
        )

        XCTAssertEqual(runs.map(\.text), ["wen", " ok"])
        XCTAssertTrue(runs.allSatisfy { $0.style.isPlain })
    }

    /// Text arrives in chunks, so an open tag styles what has arrived so far.
    func testUnclosedTagStillStylesTheRemainder() {
        let runs = MarkupParser.runs(from: "saya [bold]wen")

        XCTAssertEqual(runs.map(\.text), ["saya ", "wen"])
        XCTAssertEqual(runs.map(\.style.isBold), [false, true])
    }

    /// A tag that is still arriving must not flash as raw markup.
    func testHalfArrivedTagAtTheEndIsHidden() {
        let runs = MarkupParser.runs(from: "saya [bo")

        XCTAssertEqual(runs.map(\.text), ["saya "])
    }

    func testStrayBracketStaysLiteral() {
        let runs = MarkupParser.runs(from: "biaya [1] gratis")

        XCTAssertEqual(runs.map(\.text), ["biaya [1] gratis"])
    }

    /// Asterisks are ordinary characters here - the reason for not using
    /// Markdown in the first place.
    func testAsterisksAreNotStyling() {
        let runs = MarkupParser.runs(from: "kartu **** 1234 *syarat")

        XCTAssertEqual(runs.map(\.text), ["kartu **** 1234 *syarat"])
        XCTAssertTrue(runs.allSatisfy { $0.style.isPlain })
    }

    func testMismatchedClosingTagKeepsTheContent() {
        let runs = MarkupParser.runs(from: "[bold]wen[/strike] ok")

        XCTAssertEqual(runs.map(\.text).joined(), "wen ok")
    }

    /// Only a fragment shaped like a tag is treated as one still arriving.
    /// An unclosed bracket in ordinary copy keeps the rest of the message.
    func testUnclosedBracketInOrdinaryCopyKeepsTheText() {
        let runs = MarkupParser.runs(from: "Nilai [USD 100 per hari")

        XCTAssertEqual(runs.map(\.text).joined(), "Nilai [USD 100 per hari")
    }

    func testHalfArrivedTagIsStillHidden() {
        let runs = MarkupParser.runs(from: "saya [bo")

        XCTAssertEqual(runs.map(\.text).joined(), "saya ")
    }
}
