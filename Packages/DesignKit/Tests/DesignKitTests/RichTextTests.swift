import CoreText
import SwiftUI
import XCTest

@testable import DesignKit

@MainActor
final class RichTextTests: XCTestCase {
    func testStylesKeepTheSelectedFontFamily() throws {
        guard #available(iOS 26, *) else { return }
        let selectedFont = try XCTUnwrap(UIFont(name: "Georgia", size: 16))
        let runs = MarkupParser.runs(from: "[bold][italic]Brand text[/italic][/bold]")
        let view = RichText(runs: runs, font: Font(selectedFont), color: .primary)
        let attributed = view.attributedText(for: runs)
        let styledFont = try XCTUnwrap(attributed.runs.first?.font)
        let resolved = styledFont.resolve(in: EnvironmentValues().fontResolutionContext)

        XCTAssertEqual(CTFontCopyFamilyName(resolved.ctFont) as String, selectedFont.familyName)
        XCTAssertEqual(resolved.pointSize, selectedFont.pointSize)
        XCTAssertTrue(resolved.isBold)
        XCTAssertTrue(resolved.isItalic)
    }

    func testNativeAttributedTextCarriesLinkAndCombinedStyles() {
        let source = "[link]ocbcid://product|[bold][underline][strike]Produk[/strike][/underline][/bold][/link]"
        let runs = MarkupParser.runs(from: source)
        let view = RichText(runs: runs, font: .body, color: .primary)
        let attributed = view.attributedText(for: runs)

        XCTAssertEqual(String(attributed.characters), "Produk")
        XCTAssertEqual(attributed.runs.first?.link?.absoluteString, "ocbcid://product")
        XCTAssertNotNil(attributed.runs.first?.font)
        XCTAssertNotNil(attributed.runs.first?.underlineStyle)
        XCTAssertNotNil(attributed.runs.first?.strikethroughStyle)
    }

    func testBulletAndLongInlineLinkWrapWithinTheProposedWidth() {
        let source =
            "• [bold]Produk:[/bold] nama panjang yang membungkus ke beberapa baris.\n"
            + "  [link]https://example.com|Buka detail produk dan informasi lebih lanjut[/link]"
        let runs = MarkupParser.runs(from: source)
        let controller = UIHostingController(rootView: RichText(runs: runs, font: .body, color: .primary))
        let size = controller.sizeThatFits(in: CGSize(width: 180, height: CGFloat.greatestFiniteMagnitude))

        XCTAssertLessThanOrEqual(size.width, 180)
        XCTAssertGreaterThan(size.height, 60)
        XCTAssertTrue(size.height.isFinite)
    }

    func testMissingCallbackDiscardsLinkTapInsteadOfOpeningSystemBrowser() {
        let runs = MarkupParser.runs(from: "[link]https://example.com|Buka[/link]")
        let view = RichText(runs: runs, font: .body, color: .primary)
        var isAccepted: Bool?

        view.linkAction(URL(string: "https://example.com")!) { isAccepted = $0 }

        XCTAssertEqual(isAccepted, false)
    }

    func testLinkTapIsForwardedToHostAndHandledWithoutSystemFallback() {
        let runs = MarkupParser.runs(from: "[link]ocbcid://product|Produk[/link]")
        var receivedURL: URL?
        var isAccepted: Bool?
        let view = RichText(runs: runs, font: .body, color: .primary, onLink: { receivedURL = $0 })

        view.linkAction(URL(string: "ocbcid://product")!) { isAccepted = $0 }

        XCTAssertEqual(receivedURL?.absoluteString, "ocbcid://product")
        XCTAssertEqual(isAccepted, true)
    }
}
