//
//  ComposerFixture.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import SwiftUI

/// Composer dengan draft sendiri untuk test caret.
struct ComposerFixture: View {
    @State
    private var text = ""
    let fontFace: FontFace

    var body: some View {
        MessageComposer(
            text: $text, placeholder: "Ask about your finances", sendLabel: "Send", stopLabel: "Stop",
            fontFace: fontFace, onSend: {}
        )
    }
}
