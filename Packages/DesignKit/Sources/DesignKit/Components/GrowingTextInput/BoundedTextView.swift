//
//  BoundedTextView.swift
//  DesignKit
//
//  Created by Wendra on 16/10/26.
//

import UIKit

public final class BoundedTextView: UITextView
{
    var lineSpacing: CGFloat = 0
    private var measuredHeight: CGFloat = 0
    private var isMeasuring = false

    override public var intrinsicContentSize: CGSize
    {
        let lineHeight = font?.lineHeight ?? UIFont.preferredFont(forTextStyle: .body).lineHeight
        return CGSize(width: UIView.noIntrinsicMetric, height: max(measuredHeight, lineHeight))
    }

    override public func caretRect(for position: UITextPosition) -> CGRect
    {
        let rect = super.caretRect(for: position)
        guard text.isEmpty
        else
        {
            return rect
        }

        return CGRect(x: rect.minX, y: (bounds.height - rect.height) / 2, width: rect.width, height: rect.height)
    }

    override public func layoutSubviews()
    {
        super.layoutSubviews()
        guard bounds.width > 0, !isMeasuring
        else
        {
            return
        }

        isMeasuring = true
        let fittedHeight = sizeThatFits(
            CGSize(width: bounds.width, height: .greatestFiniteMagnitude)).height
        isMeasuring = false

        let lineHeight = font?.lineHeight ?? UIFont.preferredFont(forTextStyle: .body).lineHeight
        let lines = CGFloat(CustomSizes.maximumInputLines)
        let maxHeight = ceil(lineHeight * lines + lineSpacing * (lines - 1))
        let nextHeight = min(max(ceil(fittedHeight), ceil(lineHeight)), maxHeight)
        let isScrolling = fittedHeight > maxHeight + CustomSizes.measurementTolerance
        if isScrollEnabled != isScrolling
        {
            isScrollEnabled = isScrolling
        }

        if abs(nextHeight - measuredHeight) > CustomSizes.measurementTolerance
        {
            measuredHeight = nextHeight
            invalidateIntrinsicContentSize()
        }
    }
}
