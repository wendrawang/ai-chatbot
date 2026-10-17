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
    var lineSpacing: CGFloat = .zero
    private var measuredHeight: CGFloat = .zero
    private var measuredWidth: CGFloat = .zero

    public override var text: String! {
        didSet { remeasure() }
    }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: max(measuredHeight, lineHeight))
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        // Scroll internal juga memicu layoutSubviews; ukur ulang hanya ketika lebar berubah.
        guard bounds.width != measuredWidth else { return }
        measuredWidth = bounds.width
        remeasure()
    }

    /// Ukur seluruh teks sekali per perubahan teks, style atau lebar, bukan per frame scroll.
    func remeasure() {
        guard bounds.width > .zero else { return }
        let fitted = sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude)).height
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

// MARK: - Helpers

private extension BoundedTextView {
    var lineHeight: CGFloat {
        font?.lineHeight ?? UIFont.preferredFont(forTextStyle: .body).lineHeight
    }
}
