//
//  RichTextTests.swift
//  TanyaAIFeatureTests
//
//  Created by Wendra on 16/10/26.
//

@testable import TanyaAIFeature
import XCTest

final class RichTextTests: XCTestCase
{
    func testNestedUnicodeAndLegacyLink()
    {
        let source = "[bold]你好👨‍👩‍👧‍👦 [strike]旧[/strike][/bold] [link]demoapp://transfer|打开[/link]"
        let runs = RichTextParser.parse(source, isFinal: true)
        XCTAssertTrue(runs.contains
        {
            $0.style.isBold && $0.style.isStruckThrough
        })
        XCTAssertEqual(runs.last?.style.link?.scheme, "demoapp")
        XCTAssertTrue(runs.map(\.text).joined().contains("你好👨‍👩‍👧‍👦"))
    }

    func testSemanticColorAndSubstringLink()
    {
        let runs = RichTextParser.parse(
            "plain [color=success]ok[/color] [link=https://example.com]open[/link] end",
            isFinal: true)
        XCTAssertEqual(runs.first(where:
            {
                $0.text == "ok"
            })?.style.color, "success")
        XCTAssertEqual(runs.first(where:
            {
                $0.text == "open"
            })?.style.link?.host, "example.com")
        XCTAssertNil(runs.last?.style.link)
    }

    func testEscapesMalformedTagsAndHTMLAreSafeText()
    {
        let runs = RichTextParser.parse(
            #"\[bold\] <script>safe</script> [unknown]hello[/unknown] [broken"#,
            isFinal: true)
        let text = runs.map(\.text).joined()
        XCTAssertEqual(text, "[bold] <script>safe</script> hello [broken")
    }

    func testPartialStreamingTagDoesNotLeakMetadata()
    {
        XCTAssertEqual(RichTextParser.parse("Hi [bo", isFinal: false).map(\.text).joined(), "Hi ")
        XCTAssertEqual(RichTextParser.parse("[link]https://exam", isFinal: false).map(\.text).joined(), "")
        XCTAssertEqual(RichTextParser.parse("[link=https://example.com]打开", isFinal: false).last?.style.link, nil)
        XCTAssertEqual(
            RichTextParser.parse("[link=https://example.com]打开[/link]", isFinal: true).last?.style.link?.host,
            "example.com")
    }

    func testUnsafeLinksAndExcessiveNestingStayNonInteractive()
    {
        for value in ["javascript:alert(1)", "data:text/html,boom", "file:///private/test", "https://"]
        {
            let runs = RichTextParser.parse("[link]" + value + "|label[/link]", isFinal: true)
            XCTAssertTrue(runs.allSatisfy
            {
                $0.style.link == nil
            })
        }

        let deep = String(repeating: "[bold]", count: 100) + "safe"
        XCTAssertFalse(RichTextParser.parse(deep, isFinal: true).isEmpty)
    }
}
