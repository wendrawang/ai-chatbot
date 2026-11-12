//
//  GrowingTextInputCoordinatorTests.swift
//  DesignKitTests
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI
import Testing
import UIKit

@testable import DesignKit

/// Ketikan di editor UIKit harus sampai ke draft milik pemakai.
@MainActor
struct GrowingTextInputCoordinatorTests {
    @Test
    func typingReachesTheDraftOfTheCaller() {
        var draft = String()
        let input = GrowingTextInput(
            text: Binding(get: { draft }, set: { draft = $0 }),
            font: .systemFont(ofSize: 14),
            textColor: .black,
            accessibilityLabel: "Pesan"
        )
        let editor = BoundedTextView()
        editor.text = "Halo"
        input.makeCoordinator().textViewDidChange(editor)
        #expect(draft == "Halo")
    }
}
