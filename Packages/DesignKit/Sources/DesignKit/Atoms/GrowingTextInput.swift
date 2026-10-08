import SwiftUI
import UIKit

/// A multiline composer that stays one to four lines tall on iOS 15.
public struct GrowingTextInput: UIViewRepresentable {
    @Binding var text: String
    let font: UIFont
    let textColor: UIColor
    let accessibilityLabel: String

    public init(text: Binding<String>, font: UIFont, textColor: UIColor, accessibilityLabel: String) {
        self._text = text
        self.font = font
        self.textColor = textColor
        self.accessibilityLabel = accessibilityLabel
    }

    public func makeUIView(context: Context) -> BoundedTextView {
        let textView = BoundedTextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.adjustsFontForContentSizeCategory = false
        textView.isScrollEnabled = false
        textView.text = text
        textView.font = font
        textView.textColor = textColor
        textView.accessibilityLabel = accessibilityLabel
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return textView
    }

    public func updateUIView(_ textView: BoundedTextView, context: Context) {
        context.coordinator.parent = self
        textView.accessibilityLabel = accessibilityLabel
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

    public static func dismantleUIView(_ textView: BoundedTextView, coordinator: Coordinator) {
        textView.delegate = nil
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public final class Coordinator: NSObject, UITextViewDelegate {
        var parent: GrowingTextInput

        init(parent: GrowingTextInput) {
            self.parent = parent
        }

        public func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            textView.setNeedsLayout()
        }
    }
}

public final class BoundedTextView: UITextView {
    private var measuredHeight: CGFloat = 0
    private var isMeasuring = false

    public override var intrinsicContentSize: CGSize {
        let lineHeight = font?.lineHeight ?? UIFont.preferredFont(forTextStyle: .body).lineHeight
        return CGSize(width: UIView.noIntrinsicMetric, height: max(measuredHeight, lineHeight))
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, !isMeasuring else { return }

        isMeasuring = true
        let fittedHeight = sizeThatFits(
            CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
        ).height
        isMeasuring = false

        let lineHeight = font?.lineHeight ?? UIFont.preferredFont(forTextStyle: .body).lineHeight
        let maxHeight = ceil(lineHeight * CGFloat(DesignKitMetrics.Text.maximumInputLines))
        let nextHeight = min(max(ceil(fittedHeight), ceil(lineHeight)), maxHeight)
        let shouldScroll = fittedHeight > maxHeight + DesignKitMetrics.Layout.measurementTolerance
        if isScrollEnabled != shouldScroll {
            isScrollEnabled = shouldScroll
        }
        if abs(nextHeight - measuredHeight) > DesignKitMetrics.Layout.measurementTolerance {
            measuredHeight = nextHeight
            invalidateIntrinsicContentSize()
        }
    }
}
