//
//  BoundedTextView.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import UIKit

/// A one-to-four-line editor; additional content scrolls inside the field.
@MainActor
public final class BoundedTextView: UITextView {
    var lineSpacing = InitialValues.zeroCGFloat
    private var measuredHeight = InitialValues.zeroCGFloat
    private var isMeasuring = false

    public override var intrinsicContentSize: CGSize {
        let lineHeight = font?.lineHeight ?? UIFont.preferredFont(forTextStyle: .body).lineHeight
        return CGSize(width: UIView.noIntrinsicMetric, height: max(measuredHeight, lineHeight))
    }

    public override func caretRect(for position: UITextPosition) -> CGRect {
        let caret = super.caretRect(for: position)
        guard !hasText, !caret.isNull, !caret.isInfinite else { return caret }
        // Custom font metrics can place the empty caret above its line box's center.
        return caret.offsetBy(dx: InitialValues.zeroCGFloat, dy: bounds.midY - caret.midY)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > InitialValues.zeroCGFloat, !isMeasuring else { return }
        isMeasuring = true
        let fitted = sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude)).height
        isMeasuring = false
        let lineHeight = font?.lineHeight ?? UIFont.preferredFont(forTextStyle: .body).lineHeight
        let lines = CGFloat(CustomSizes.InputText.maximumLines)
        let gaps = lines - CGFloat(CustomSizes.InputText.minimumLines)
        let maximumHeight = ceil(lineHeight * lines + lineSpacing * gaps)
        let nextHeight = min(max(ceil(fitted), ceil(lineHeight)), maximumHeight)
        let isScrolling = fitted > maximumHeight + CustomSizes.Layout.measurementTolerance
        if isScrollEnabled != isScrolling { isScrollEnabled = isScrolling }
        if abs(nextHeight - measuredHeight) > CustomSizes.Layout.measurementTolerance {
            measuredHeight = nextHeight
            invalidateIntrinsicContentSize()
        }
    }
}
