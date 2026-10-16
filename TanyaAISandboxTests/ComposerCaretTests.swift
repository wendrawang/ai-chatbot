//
//  ComposerCaretTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import SwiftUI
import XCTest

@MainActor
final class ComposerCaretTests: XCTestCase {
    func testEmptyFocusedCaretIsCenteredAcrossFontCatalogAndAfterClearing() throws {
        try FontFace.registerFonts()
        for face in FontFace.allCases {
            let fixture = try HostWindowFixture(ComposerFixture(fontFace: face).frame(width: 343))
            defer { fixture.close() }
            let editor = try XCTUnwrap(findEditor(in: fixture.controller.view))
            XCTAssertTrue(editor.becomeFirstResponder())
            fixture.settle()
            XCTAssertEqual(editor.caretRect(for: editor.beginningOfDocument).midY, editor.bounds.midY, accuracy: 0.01)
            let emptyHeight = editor.bounds.height
            editor.insertText("Ag")
            fixture.settle()
            editor.deleteBackward()
            editor.deleteBackward()
            fixture.settle()
            XCTAssertTrue(editor.text.isEmpty)
            XCTAssertEqual(editor.bounds.height, emptyHeight, accuracy: 0.01)
            XCTAssertEqual(editor.caretRect(for: editor.beginningOfDocument).midY, editor.bounds.midY, accuracy: 0.01)
        }
    }

    private func findEditor(in view: UIView) -> BoundedTextView? {
        if let editor = view as? BoundedTextView { return editor }
        return view.subviews.lazy.compactMap { self.findEditor(in: $0) }.first
    }
}

@MainActor
private struct ComposerFixture: View {
    @State
    private var text = ""
    let fontFace: FontFace

    var body: some View {
        MessageComposer(
            text: $text, placeholder: "Ask about your finances", sendLabel: "Send", fontFace: fontFace, onSend: {}
        )
    }
}
