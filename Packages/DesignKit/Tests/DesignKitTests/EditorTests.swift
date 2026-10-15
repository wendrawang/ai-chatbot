import SwiftUI
import XCTest

@testable import DesignKit

@MainActor
final class EditorTests: XCTestCase {
    func testEditorGrowsToFourLinesThenScrollsAndShrinksWhenCleared() throws {
        try FontFace.registerFonts()
        let editor = BoundedTextView(frame: CGRect(x: 0, y: 0, width: 220, height: 300))
        editor.font = FontFace.regular.font(size: 16)
        editor.textContainerInset = .zero
        editor.textContainer.lineFragmentPadding = 0
        editor.isScrollEnabled = false
        editor.text = "One"
        editor.layoutSubviews()
        let firstHeight = editor.intrinsicContentSize.height
        editor.text = "One\nTwo\nThree\nFour"
        editor.layoutSubviews()
        let fourthHeight = editor.intrinsicContentSize.height
        XCTAssertGreaterThan(fourthHeight, firstHeight)
        editor.text += "\nFive\n" + String(repeating: "m", count: 128)
        editor.layoutSubviews()
        XCTAssertEqual(editor.intrinsicContentSize.height, fourthHeight, accuracy: 1)
        XCTAssertTrue(editor.isScrollEnabled)
        XCTAssertEqual(editor.intrinsicContentSize.width, UIView.noIntrinsicMetric)
        editor.text = ""
        editor.layoutSubviews()
        XCTAssertLessThan(editor.intrinsicContentSize.height, fourthHeight)
        XCTAssertFalse(editor.isScrollEnabled)
    }

    func testComposerAdaptsFontAndWrapsWithoutGrowingHorizontally() throws {
        try FontFace.registerFonts()
        for width: CGFloat in [320, 375, 430] {
            for category: ContentSizeCategory in [.large, .accessibilityExtraExtraExtraLarge] {
                let content = MessageComposer(
                    text: .constant(String(repeating: "中文 English ", count: 20)),
                    placeholder: "咨询财务及服务…", sendLabel: "发送消息", onSend: {}
                )
                .environment(\.sizeCategory, category)
                let controller = UIHostingController(rootView: content)
                controller.view.frame = CGRect(x: 0, y: 0, width: width, height: 800)
                controller.view.layoutIfNeeded()
                let size = controller.sizeThatFits(in: CGSize(width: width, height: 2_000))
                XCTAssertLessThanOrEqual(size.width, width + 1)
                XCTAssertTrue(size.height.isFinite && size.height > 0 && size.height < 1_000)
            }
        }
    }
}
