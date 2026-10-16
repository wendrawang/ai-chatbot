//
//  GrowingTextInput.swift
//  DesignKit
//
//  Created by Wendra on 16/10/26.
//

import SwiftUI
import UIKit

/// A multiline composer that stays one to four lines tall on iOS 15.
public struct GrowingTextInput: UIViewRepresentable
{
    @Binding
    var text: String
    let font: UIFont
    let lineSpacing: CGFloat
    let textColor: UIColor
    let accessibilityLabel: String

    public init(
        text: Binding<String>, font: UIFont, textColor: UIColor,
        lineSpacing: CGFloat = 0, accessibilityLabel: String)
    {
        self._text = text
        self.font = font
        self.lineSpacing = lineSpacing
        self.textColor = textColor
        self.accessibilityLabel = accessibilityLabel
    }

    public func makeUIView(context: Context) -> BoundedTextView
    {
        let textView = BoundedTextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.adjustsFontForContentSizeCategory = false
        textView.isScrollEnabled = false
        textView.text = text
        applyStyle(to: textView)
        textView.accessibilityLabel = accessibilityLabel
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return textView
    }

    public func updateUIView(_ textView: BoundedTextView, context: Context)
    {
        context.coordinator.parent = self
        textView.accessibilityLabel = accessibilityLabel
        if textView.font != font || textView.textColor != textColor || textView.lineSpacing != lineSpacing
        {
            applyStyle(to: textView)
        }

        if textView.text != text
        {
            textView.text = text
            applyStyle(to: textView)
        }

        textView.setNeedsLayout()
    }

    private func applyStyle(to textView: BoundedTextView)
    {
        guard textView.markedTextRange == nil
        else
        {
            return
        }

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = max(0, lineSpacing)
        textView.lineSpacing = paragraph.lineSpacing
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font, .foregroundColor: textColor, .paragraphStyle: paragraph,
        ]
        textView.font = font
        textView.textColor = textColor
        textView.typingAttributes = attributes
        let selection = textView.selectedRange
        textView.textStorage.addAttributes(attributes, range: NSRange(location: 0, length: textView.textStorage.length))
        textView.selectedRange = selection
    }

    public static func dismantleUIView(_ textView: BoundedTextView, coordinator _: Coordinator)
    {
        textView.delegate = nil
    }

    public func makeCoordinator() -> Coordinator
    {
        Coordinator(parent: self)
    }

    public final class Coordinator: NSObject, UITextViewDelegate
    {
        var parent: GrowingTextInput

        init(parent: GrowingTextInput)
        {
            self.parent = parent
        }

        public func textViewDidChange(_ textView: UITextView)
        {
            parent.text = textView.text
            textView.setNeedsLayout()
        }
    }
}
