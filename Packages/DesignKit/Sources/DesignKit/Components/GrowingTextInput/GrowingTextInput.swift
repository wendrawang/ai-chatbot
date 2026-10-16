//
//  GrowingTextInput.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import SwiftUI
import UIKit

/// The UIKit bridge owns measurement and selection; the caller owns the draft and font.
@MainActor
public struct GrowingTextInput: UIViewRepresentable {
    @Binding
    private var text: String
    private let font: UIFont
    private let textColor: UIColor
    private let lineSpacing: CGFloat
    private let accessibilityLabel: String

    public init(
        text: Binding<String>, font: UIFont, textColor: UIColor,
        lineSpacing: CGFloat = InitialValues.zeroCGFloat, accessibilityLabel: String
    ) {
        self._text = text
        self.font = font
        self.textColor = textColor
        self.lineSpacing = lineSpacing
        self.accessibilityLabel = accessibilityLabel
    }

    public func makeUIView(context: Context) -> BoundedTextView {
        let editor = BoundedTextView()
        editor.delegate = context.coordinator
        editor.backgroundColor = UIColor(CustomColors.transparent)
        editor.textContainerInset = .zero
        editor.textContainer.lineFragmentPadding = InitialValues.zeroCGFloat
        editor.adjustsFontForContentSizeCategory = false
        editor.isScrollEnabled = false
        editor.text = text
        editor.setContentHuggingPriority(.defaultLow, for: .horizontal)
        applyStyle(to: editor)
        editor.accessibilityLabel = accessibilityLabel
        return editor
    }

    public func updateUIView(_ editor: BoundedTextView, context: Context) {
        context.coordinator.parent = self
        editor.accessibilityLabel = accessibilityLabel
        if editor.font != font || editor.textColor != textColor || editor.lineSpacing != lineSpacing {
            applyStyle(to: editor)
        }
        if editor.text != text {
            editor.text = text
            applyStyle(to: editor)
        }
        editor.setNeedsLayout()
    }

    public func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    public static func dismantleUIView(_ editor: BoundedTextView, coordinator: Coordinator) {
        editor.delegate = nil
    }

    public final class Coordinator: NSObject, UITextViewDelegate {
        var parent: GrowingTextInput
        init(parent: GrowingTextInput) { self.parent = parent }

        public func textViewDidChange(_ editor: UITextView) {
            parent.text = editor.text
            editor.setNeedsLayout()
        }
    }
}

// MARK: - Helpers

private extension GrowingTextInput {
    func applyStyle(to editor: BoundedTextView) {
        guard editor.markedTextRange == nil else { return }
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = max(InitialValues.zeroCGFloat, lineSpacing)
        editor.lineSpacing = paragraph.lineSpacing
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font, .foregroundColor: textColor, .paragraphStyle: paragraph
        ]
        editor.font = font
        editor.textColor = textColor
        editor.typingAttributes = attributes
        let selection = editor.selectedRange
        editor.textStorage.addAttributes(
            attributes, range: NSRange(location: InitialValues.zeroInteger, length: editor.textStorage.length)
        )
        editor.selectedRange = selection
    }
}
