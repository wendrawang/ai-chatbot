import XCTest

@testable import DesignKit

final class MarkupLinkTests: XCTestCase {
    func testWebLinkShowsOnlyLabelAndCarriesItsDestination() {
        let runs = MarkupParser.runs(from: "Open [link]https://www.google.com|Buka Google[/link].")

        XCTAssertEqual(runs.map(\.text).joined(), "Open Buka Google.")
        XCTAssertNil(runs.first?.style.linkURL)
        XCTAssertEqual(runs[1].style.linkURL?.absoluteString, "https://www.google.com")
        XCTAssertNil(runs.last?.style.linkURL)
    }

    func testAppDeepLinkIsPreservedWithoutTransformingItsQuery() {
        let target = "ocbcid://mobile?type=product&message=Beli%20produk"
        let runs = MarkupParser.runs(from: "[link]\(target)|Lihat produk[/link]")

        XCTAssertEqual(runs.map(\.text).joined(), "Lihat produk")
        XCTAssertEqual(runs.first?.style.linkURL?.absoluteString, target)
    }

    func testNestedColorDelimiterDoesNotReplaceLinkTarget() {
        let runs = MarkupParser.runs(
            from: "[link]https://example.com|Buka [bold][color]Google|25C36B[/color][/bold][/link]"
        )

        XCTAssertEqual(runs.map(\.text).joined(), "Buka Google")
        XCTAssertTrue(runs.allSatisfy { $0.style.linkURL?.absoluteString == "https://example.com" })
        XCTAssertTrue(runs.last?.style.isBold == true)
        XCTAssertEqual(runs.last?.style.colorHex, "25C36B")
    }

    func testOuterColorKeepsInnerLinkTargetAndStyle() {
        let runs = MarkupParser.runs(
            from: "[color][strike][link]ocbcid://product|Produk[/link][/strike]|D308E5[/color]"
        )

        XCTAssertEqual(runs.map(\.text).joined(), "Produk")
        XCTAssertEqual(runs.first?.style.linkURL?.absoluteString, "ocbcid://product")
        XCTAssertEqual(runs.first?.style.colorHex, "D308E5")
        XCTAssertTrue(runs.first?.style.isStruckThrough == true)
    }

    func testTargetStillStreamingNeverFlashesOnScreen() {
        for source in ["[link]", "[link]https://", "[link]https://example.com", "[li"] {
            XCTAssertEqual(MarkupParser.runs(from: source).map(\.text).joined(), "")
        }
    }

    func testLabelCanRenderBeforeClosingTagArrives() {
        let runs = MarkupParser.runs(from: "[link]https://example.com|Buka [bold]Goo[/bo")

        XCTAssertEqual(runs.map(\.text).joined(), "Buka Goo")
        XCTAssertTrue(runs.last?.style.isBold == true)
        XCTAssertTrue(runs.allSatisfy { $0.style.linkURL?.absoluteString == "https://example.com" })
    }

    func testInvalidTargetsKeepLabelsWithoutMakingThemClickable() {
        for target in [
            "not-a-url", "https://", "https://exa mple.com", "ocbcid:", "ocbcid://", "javascript:alert(1)",
            "file:///tmp/a"
        ] {
            let runs = MarkupParser.runs(from: "[link]\(target)|[bold]Label[/bold][/link]")
            XCTAssertEqual(runs.map(\.text).joined(), "Label")
            XCTAssertNil(runs.first?.style.linkURL)
            XCTAssertTrue(runs.first?.style.isBold == true)
        }
    }

    func testDepthFallbackDoesNotExposeLinkTargetOrPartialTag() {
        let source =
            String(repeating: "[bold]", count: 40)
            + "[link]https://example.com|Label[/link] [bo"
        let runs = MarkupParser.runs(from: source)

        XCTAssertEqual(runs.map(\.text).joined(), "Label ")
        XCTAssertTrue(runs.allSatisfy { $0.style.isPlain })
    }

    func testMultipleLinksAndLiteralPipesInLabelRemainIndependent() {
        let runs = MarkupParser.runs(
            from: "[link]https://example.com|A|B[/link] [link]ocbcid://product|C[/link]"
        )

        XCTAssertEqual(runs.map(\.text).joined(), "A|B C")
        XCTAssertEqual(runs.first?.style.linkURL?.absoluteString, "https://example.com")
        XCTAssertEqual(runs.last?.style.linkURL?.absoluteString, "ocbcid://product")
    }

    func testClosingLinkEndsTapAreaDespiteUnclosedNestedStyle() {
        let runs = MarkupParser.runs(from: "[link]https://example.com|[bold]Label[/link] plain text")

        XCTAssertEqual(runs.map(\.text).joined(), "Label plain text")
        XCTAssertEqual(runs.first?.style.linkURL?.absoluteString, "https://example.com")
        XCTAssertTrue(runs.first?.style.isBold == true)
        XCTAssertNil(runs.last?.style.linkURL)
        XCTAssertFalse(runs.last?.style.isBold == true)
    }

    func testMismatchedLinkClosingKeepsOnlyNonInteractiveLabel() {
        let runs = MarkupParser.runs(from: "[link]https://example.com|Label[/strike] plain text")

        XCTAssertEqual(runs.map(\.text).joined(), "Label plain text")
        XCTAssertTrue(runs.allSatisfy { $0.style.linkURL == nil })
    }
}
