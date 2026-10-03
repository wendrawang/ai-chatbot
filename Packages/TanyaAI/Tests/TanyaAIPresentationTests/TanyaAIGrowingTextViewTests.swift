@testable import DesignKit
import SwiftUI
import UIKit
import XCTest
@testable import TanyaAIPresentation

final class TanyaAIGrowingTextViewTests: XCTestCase {
    func testCaptureComposerLineCounts() {
        let viewModel = TanyaAIChatViewModel(useCase: TanyaAIChatUseCaseStub())
        let content = ComposerFixture(viewModel: viewModel)
        let controller = UIHostingController(rootView: content)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 280))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        defer { window.isHidden = true }

        let examples = [
            ("composer-empty", ""),
            ("composer-1-line", "Halo Wen"),
            ("composer-4-lines", "Baris pertama\nBaris kedua\nBaris ketiga\nBaris keempat"),
            (
                "composer-over-4-lines",
                "Baris pertama\nBaris kedua\nBaris ketiga\nBaris keempat\nBaris kelima\nBaris keenam"
            )
        ]
        var heights: [CGFloat] = []
        for (name, text) in examples {
            viewModel.inputText = text
            RunLoop.main.run(until: Date().addingTimeInterval(0.4))
            window.layoutIfNeeded()
            controller.view.layoutIfNeeded()
            guard let field = findTextView(in: controller.view) else {
                XCTFail("Composer text view not mounted")
                return
            }
            field.layoutIfNeeded()
            field.setContentOffset(
                CGPoint(x: 0, y: max(0, field.contentSize.height - field.bounds.height)),
                animated: false
            )
            RunLoop.main.run(until: Date().addingTimeInterval(0.1))
            window.layoutIfNeeded()
            heights.append(field.frame.height)

            attachScreenshot(of: window, name: name)
        }
        XCTAssertEqual(heights.count, 4)
        XCTAssertGreaterThan(heights[2], heights[1])
        XCTAssertEqual(heights[3], heights[2], accuracy: 1)
        XCTAssertTrue(findTextView(in: controller.view)?.isScrollEnabled == true)
    }

    private func attachScreenshot(of window: UIWindow, name: String) {
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        let image = renderer.image { context in
            window.layer.render(in: context.cgContext)
        }
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func findTextView(in view: UIView) -> BoundedTextView? {
        if let textView = view as? BoundedTextView { return textView }
        return view.subviews.lazy.compactMap(findTextView).first
    }

    func testComposerGrowsThenScrollsAfterFourLines() {
        let textView = BoundedTextView(
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

private struct ComposerFixture: View {
    @ObservedObject var viewModel: TanyaAIChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            MessageComposer(
                text: $viewModel.inputText,
                placeholder: "Message", sendLabel: "Send", stopLabel: "Stop", isGenerating: false,
                onSend: {}, onStop: {}
            )
        }
        .background(Color.white)
    }
}
