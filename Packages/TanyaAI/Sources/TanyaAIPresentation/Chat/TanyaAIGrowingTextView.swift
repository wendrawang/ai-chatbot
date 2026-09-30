import SwiftUI
import UIKit

/// A multiline composer that stays one to four lines tall on iOS 15.
struct TanyaAIGrowingTextView: UIViewRepresentable {
    @Binding var text: String
    let font: UIFont
    let textColor: UIColor

    func makeUIView(context: Context) -> TanyaAIBoundedTextView {
        let textView = TanyaAIBoundedTextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.adjustsFontForContentSizeCategory = true
        textView.isScrollEnabled = false
        textView.text = text
        textView.accessibilityLabel = "Ask Tanya AI"
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return textView
    }

    func updateUIView(_ textView: TanyaAIBoundedTextView, context: Context) {
        context.coordinator.parent = self
        if textView.font != font {
            textView.font = font
        }
        if textView.textColor != textColor {
            textView.textColor = textColor
        }
        if textView.text != text {
            textView.text = text
        }
        textView.setNeedsLayout()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: TanyaAIGrowingTextView

        init(parent: TanyaAIGrowingTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            textView.setNeedsLayout()
        }
    }
}

final class TanyaAIBoundedTextView: UITextView {
    private var measuredHeight: CGFloat = 0
    private var isMeasuring = false

    override var intrinsicContentSize: CGSize {
        let lineHeight = font?.lineHeight ?? 20
        return CGSize(width: UIView.noIntrinsicMetric, height: max(measuredHeight, lineHeight))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, !isMeasuring else { return }

        isMeasuring = true
        let fittedHeight = sizeThatFits(
            CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
        ).height
        isMeasuring = false

        let lineHeight = font?.lineHeight ?? 20
        let maxHeight = ceil(lineHeight * 4)
        let nextHeight = min(max(ceil(fittedHeight), ceil(lineHeight)), maxHeight)
        let shouldScroll = fittedHeight > maxHeight + 0.5
        if isScrollEnabled != shouldScroll {
            isScrollEnabled = shouldScroll
        }
        if abs(nextHeight - measuredHeight) > 0.5 {
            measuredHeight = nextHeight
            invalidateIntrinsicContentSize()
        }
    }
}
