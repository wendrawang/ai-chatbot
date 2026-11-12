//
//  GrowingTextInput.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import SwiftUI
import UIKit

/// Jembatan UIKit mengurus pengukuran dan seleksi; draft dan font milik pemakai.
@MainActor
public struct GrowingTextInput: UIViewRepresentable {
    @Binding private var text: String
    private let font: UIFont
    private let textColor: UIColor
    private let lineSpacing: CGFloat
    private let accessibilityLabel: String

    public init(
        text: Binding<String>,
        font: UIFont,
        textColor: UIColor,
        lineSpacing: CGFloat = .zero,
        accessibilityLabel: String
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
        editor.backgroundColor = .clear
        editor.textContainerInset = .zero
        editor.textContainer.lineFragmentPadding = .zero
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
        let isStyleChanged = editor.font != font || editor.textColor != textColor || editor.lineSpacing != lineSpacing
        let isTextChanged = editor.text != text
        if isTextChanged { editor.text = text }
        guard isStyleChanged || isTextChanged else { return }
        applyStyle(to: editor)
        editor.remeasure()
    }

    public func makeCoordinator() -> GrowingTextInputCoordinator { GrowingTextInputCoordinator(parent: self) }

    public static func dismantleUIView(_ editor: BoundedTextView, coordinator: GrowingTextInputCoordinator) {
        editor.delegate = nil
    }

    /// Teks dari editor ke draft pemakai; dipanggil coordinator setiap isi editor berubah.
    func updateDraft(_ draft: String) {
        text = draft
    }
}

// MARK: - Helpers

private extension GrowingTextInput {
    func applyStyle(to editor: BoundedTextView) {
        guard editor.markedTextRange == nil else { return }
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = max(.zero, lineSpacing)
        editor.lineSpacing = paragraph.lineSpacing
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font, .foregroundColor: textColor, .paragraphStyle: paragraph
        ]
        editor.font = font
        editor.textColor = textColor
        editor.typingAttributes = attributes
        let selection = editor.selectedRange
        editor.textStorage.addAttributes(
            attributes,
            range: NSRange(location: .zero, length: editor.textStorage.length)
        )
        editor.selectedRange = selection
    }
}
