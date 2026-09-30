import UIKit
import XCTest
@testable import TanyaAIPresentation

final class TanyaAIGrowingTextViewTests: XCTestCase {
    func testComposerGrowsThenScrollsAfterFourLines() {
        let textView = TanyaAIBoundedTextView(
            frame: CGRect(x: 0, y: 0, width: 240, height: 100)
        )
        textView.font = .systemFont(ofSize: 16)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0

        textView.text = "one"
        textView.layoutSubviews()
        let oneLineHeight = textView.intrinsicContentSize.height

        textView.text = "one\ntwo\nthree\nfour"
        textView.layoutSubviews()
        let fourLineHeight = textView.intrinsicContentSize.height
        XCTAssertGreaterThan(fourLineHeight, oneLineHeight)
        XCTAssertFalse(textView.isScrollEnabled)

        textView.text = "one\ntwo\nthree\nfour\nfive\nsix"
        textView.layoutSubviews()
        XCTAssertEqual(textView.intrinsicContentSize.height, fourLineHeight, accuracy: 1)
        XCTAssertTrue(textView.isScrollEnabled)

        textView.text = "one\ntwo"
        textView.layoutSubviews()
        XCTAssertLessThan(textView.intrinsicContentSize.height, fourLineHeight)
        XCTAssertFalse(textView.isScrollEnabled)
    }
}
