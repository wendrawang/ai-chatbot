//
//  GrowingTextInput.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import SwiftUI
import UIKit

/// Jembatan ke editor UIKit: pengukuran dan seleksi di sini; draft dan font milik pemakai. `.disabled(...)` dari
/// pemakai membuat editor tidak bisa diketik dan menutup keyboard-nya; warna nonaktif tetap milik pemakai.
/// `onFocusChange` dipanggil saat editor mulai (true) dan selesai (false) diketik. `focusRequest` = token fokus:
/// setiap UUID baru meminta fokus sekali (mis. tap di luar teks pada kartu pemakai); nilai awal dan render ulang
/// dengan nilai yang sama tidak membuka keyboard.
@MainActor
public struct GrowingTextInput: UIViewRepresentable {
    @Environment(\.isEnabled) private var isEnabled
    @Binding private var text: String
    private let font: UIFont
    private let textColor: UIColor
    private let lineSpacing: CGFloat
    private let accessibilityLabel: String
    private let focusRequest: UUID?
    private let onFocusChange: ((Bool) -> Void)?

    public init(
        text: Binding<String>,
        font: UIFont,
        textColor: UIColor,
        lineSpacing: CGFloat = .zero,
        accessibilityLabel: String,
        focusRequest: UUID? = nil,
        onFocusChange: ((Bool) -> Void)? = nil
    ) {
        self._text = text
        self.font = font
        self.textColor = textColor
        self.lineSpacing = lineSpacing
        self.accessibilityLabel = accessibilityLabel
        self.focusRequest = focusRequest
        self.onFocusChange = onFocusChange
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
        applyEnabled(to: editor)
        editor.setContentHuggingPriority(.defaultLow, for: .horizontal)
        applyStyle(to: editor)
        editor.accessibilityLabel = accessibilityLabel
        return editor
    }

    public func updateUIView(_ editor: BoundedTextView, context: Context) {
        context.coordinator.parent = self
        editor.accessibilityLabel = accessibilityLabel
        applyEnabled(to: editor)
        applyFocusRequest(to: editor, coordinator: context.coordinator)
        let isStyleChanged = editor.font != font || editor.textColor != textColor || editor.lineSpacing != lineSpacing
        let isTextChanged = editor.text != text
        if isTextChanged { editor.text = text }
        guard isStyleChanged || isTextChanged else { return }
        applyStyle(to: editor)
        editor.remeasure()
    }

    public func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    public static func dismantleUIView(_ editor: BoundedTextView, coordinator: Coordinator) {
        editor.delegate = nil
    }

    public final class Coordinator: NSObject, UITextViewDelegate {
        var parent: GrowingTextInput
        private var handledFocusRequest: UUID?

        init(parent: GrowingTextInput) {
            self.parent = parent
            self.handledFocusRequest = parent.focusRequest
        }

        /// True sekali untuk setiap token baru, jadi render ulang dengan token yang sama tidak membuka keyboard lagi.
        func isNewFocusRequest(_ request: UUID?) -> Bool {
            guard request != handledFocusRequest else { return false }
            handledFocusRequest = request
            return true
        }

        public func textViewDidChange(_ editor: UITextView) {
            // UITextView.text bertipe String!; baca sebagai optional agar tidak ada unwrap paksa.
            parent.text = editor.text ?? String()
            (editor as? BoundedTextView)?.remeasure()
        }

        public func textViewDidBeginEditing(_ editor: UITextView) {
            parent.onFocusChange?(true)
        }

        public func textViewDidEndEditing(_ editor: UITextView) {
            parent.onFocusChange?(false)
        }
    }
}

// MARK: - Helpers

private extension GrowingTextInput {
    /// Editor yang dinonaktifkan selagi fokus melepas fokusnya, jadi keyboard tidak tertinggal terbuka.
    func applyEnabled(to editor: BoundedTextView) {
        guard editor.isEditable != isEnabled else { return }
        editor.isEditable = isEnabled
        guard !isEnabled, editor.isFirstResponder else { return }
        editor.resignFirstResponder()
    }

    /// Fokus diminta di antrean main berikutnya: delegate fokus mengubah state pemakai, dan perubahan itu tidak boleh
    /// terjadi di tengah update SwiftUI. Editor yang nonaktif atau sudah lepas dari window diabaikan.
    func applyFocusRequest(to editor: BoundedTextView, coordinator: Coordinator) {
        guard coordinator.isNewFocusRequest(focusRequest), editor.isEditable else { return }
        DispatchQueue.main.async { [weak editor] in
            guard let editor, editor.isEditable, editor.window != nil, !editor.isFirstResponder else { return }
            editor.becomeFirstResponder()
        }
    }

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
            attributes, range: NSRange(location: .zero, length: editor.textStorage.length)
        )
        editor.selectedRange = selection
    }
}
